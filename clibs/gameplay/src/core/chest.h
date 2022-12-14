#pragma once

#include <list>
#include <memory>
#include <optional>
#include <span>
#include <vector>
#include <assert.h>
#include <stdint.h>
#include <util/component.h>
extern "C" {
#include "util/prototype.h"
}

struct world;
struct lua_State;

struct recipe_items {
    uint16_t n;
    uint16_t unused = 0;
    struct {
        uint16_t item;
        uint16_t amount;
    } items[1];
};

struct container_slot {
    enum class slot_type: uint8_t {
        red = 0,
        blue,
        green,
    };
    enum class slot_unit: uint8_t {
        list,
        array,
        head,
    };
    slot_type type;
    slot_unit unit;
    uint16_t item;
    uint16_t amount;
    uint16_t limit;
    uint16_t lock_item;
    uint16_t lock_space;
};

class container {
public:
    using size_type = uint16_t;
    static constexpr size_type kPageSize = 256;
    struct index {
        uint8_t page;
        uint8_t slot;
        index operator+(uint8_t v) const {
            assert((size_t)slot + v < kPageSize);
            return {page, (uint8_t)(slot + v)};
        }
        bool operator==(const index& rhs) const {
            return page == rhs.page && slot == rhs.slot;
        }
        operator const uint16_t&() const {
            return *(uint16_t*)this;
        }
        static index from(uint16_t v) {
            return *(index*)&v;
        }
    };
    struct slot : public container_slot {
        index next;
        void init() {
            type = container_slot::slot_type::red;
            unit = container_slot::slot_unit::list;
            item = 0;
            amount = 0;
            limit = 0;
            lock_item = 0;
            lock_space = 0;
            next = container::kInvalidIndex;
        }
    };
    struct page {
        slot slots[kPageSize];
    };
    struct chunk {
    public:
        chunk() {} // for saveload
        chunk(uint8_t slot, size_type length)
            : slot(slot)
        {
            assert(1 <= length && length <= 256);
            this->length = (uint8_t)(length-1);
        }
        bool operator<(const chunk& rhs) const {
            return slot < rhs.slot;
        }
        size_type size() const {
            return length + 1;
        }
        void add_size(const chunk& rhs) {
            assert(length + rhs.size() < kPageSize);
            length += rhs.size();
        }
        void sub_size(size_type size) {
            assert(size < length);
            length -= size;
        }
        uint8_t slot;
    private:
        uint8_t length;
    };
    static constexpr index kInvalidIndex = {0,0};
public:
    container() {
        init();
    }
    index create_chest(size_type asize, size_type lsize) {
        assert(asize <= kPageSize && lsize <= kPageSize);
        auto start = alloc_list(1);
        if (asize == 0) {
            if (lsize != 0) {
                alloc_list(start, lsize);
            }
            return start;
        }
        auto array_start = alloc_array(asize);
        at(start).next = array_start;
        if (lsize == 0) {
            return start;
        }
        index l = array_start + (uint8_t)(asize-1);
        alloc_list(l, lsize);
        return start;
    }
    slot& at(index idx) {
        assert(idx.page < pages.size());
        return pages[idx.page]->slots[idx.slot];
    }
    std::span<slot> slice(index idx, size_type size) {
        assert(idx.page < pages.size());
        return {pages[idx.page]->slots + idx.slot, size};
    }
    void init() {
        pages.emplace_back(new page);
        top = 0;
        alloc_array_(1);
    }
    void clear() {
        pages.clear();
        freelist.clear();
    }
    index alloc_slot(size_type size) {
        return alloc_list(size);
    }
    void free_slot(index idx) {
        free_chunk(idx.page, {idx.slot, 1});
    }
private:
    void init_array(index start, size_type size) {
        size_type last = (size_type)(size-1);
        for (size_type i = 0; i < last; ++i) {
            pages[start.page]->slots[start.slot+i].next = {start.page, (uint8_t)(start.slot + i+1)};
        }
        pages[start.page]->slots[start.slot+last].next = kInvalidIndex;
    }
    index alloc_array_(size_type size) {
        assert(size <= kPageSize);
        uint8_t page;
        uint8_t slot;
        if (size + top <= kPageSize) {
            page = (uint8_t)(pages.size()-1);
            slot = top;
            top += size;
        }
        else if (size == kPageSize) {
            free_page();
            alloc_page();
            page = (uint8_t)(pages.size()-1);
            slot = 0;
            alloc_page();
        }
        else {
            free_page();
            alloc_page();
            page = (uint8_t)(pages.size()-1);
            slot = 0;
            top = (uint8_t)size;
        }
        index start {page, slot};
        init_array(start, size);
        return start;
    }
    index alloc_array(size_type size) {
        for (size_t i = 0; i < freelist.size(); ++i) {
            auto& lst = freelist[i];
            for (auto it = lst.begin(); it != lst.end(); ++it) {
                if (it->size() >= size) {
                    index start {(uint8_t)i, it->slot};
                    if (it->size() == size) {
                        lst.erase(it);
                    }
                    else {
                        it->slot += size;
                        it->sub_size(size);
                    }
                    init_array(start, size);
                    return start;
                }
            }
        }
        return alloc_array_(size);
    }
    index alloc_list(size_type size) {
        for (size_t i = 0; i < freelist.size(); ++i) {
            auto& lst = freelist[i];
            for (auto it = lst.begin(); it != lst.end(); ++it) {
                if (it->size() < size) {
                    index start {(uint8_t)i, it->slot};
                    lst.erase(it);
                    init_array(start, it->size());
                    alloc_list(start, size-it->size());
                    return start;
                }
                else {
                    return alloc_array(size);
                }
            }
        }
        return alloc_array_(size);
    }
    void alloc_list(index start, size_type size) {
        at(start).next = alloc_list(size);
    }
    void free_array(index idx, size_type size) {
        free_chunk(idx.page, {idx.slot, size});
    }
    void free_list(index idx, size_type size) {
        for (size_type i = 0; i < size; ++i) {
            free_chunk(idx.page, {idx.slot, 1});
            idx = at(idx).next;
        }
    }
    void free_page() {
        free_chunk((uint8_t)(pages.size()-1), {top, size_type(kPageSize - top)});
    }
    void alloc_page() {
        assert(pages.size() <= 255);
        pages.emplace_back(new page);
        top = 0;
    }
    void free_chunk(uint8_t page, chunk c) {
        if (page+1 > freelist.size()) {
            freelist.resize(page+1);
        }
        auto& lst = freelist[page];
        for (auto it = lst.begin(); it != lst.end(); ++it) {
            if (c < *it) {
                auto p = lst.insert(it, c);
                while (true) {
                    auto next = ++p;
                    if (p->slot + p->size() != next->slot) {
                        assert(p->slot + p->size() < next->slot);
                        break;
                    }
                    p->add_size(*next);
                    lst.erase(next);
                }
                while (true) {
                    auto prev = --p;
                    if (prev->slot + prev->size() != p->slot) {
                        assert(prev->slot + prev->size() < p->slot);
                        break;
                    }
                    p->slot = prev->slot;
                    p->add_size(*prev);
                    lst.erase(prev);
                }
                break;
            }
        }
    }
public: //TODO for saveload
    std::vector<std::unique_ptr<page>> pages;
    std::vector<std::list<chunk>> freelist;
    uint8_t top;
};

namespace chest {
    struct chest_data {
        container::index index;
        container::size_type asize;
    };

    container::index create(world& w, uint16_t endpoint, container_slot* data, container::size_type asize, container::size_type lsize);
    void add(world& w, container::index index, uint16_t endpoint, container_slot* data, container::size_type lsize);
    chest_data& query(ecs::chest& c);
    container::index head(world& w, container::index start);
    container::slot& array_at(world& w, container::index start, uint8_t offset);
    std::span<container::slot> array_slice(world& w, container::index start, uint8_t offset, uint16_t size);

    // for fluidflow
    uint16_t get_fluid(world& w, chest_data& c, uint8_t offset);
    void     set_fluid(world& w, chest_data& c, uint8_t offset, uint16_t value);

    // for chest
    bool     pickup(world& w, chest_data& c, uint16_t endpoint, prototype_context& recipe);
    bool     place(world& w, chest_data& c, uint16_t endpoint, prototype_context& recipe);

    // for laboratory
    bool     pickup(world& w, chest_data& c, uint16_t endpoint, const recipe_items* r, uint8_t offset = 0);
    bool     place(world& w, chest_data& c, uint16_t endpoint, const recipe_items* r, uint8_t offset = 0);
    bool     recover(world& w, chest_data& c, const recipe_items* r, uint8_t offset = 0);
    void     limit(world& w, chest_data& c, uint16_t endpoint, const uint16_t* r);
    size_t   size(chest_data& c);

    // for lua api
    const container_slot* getslot(world& w, container::index index, uint8_t offset);
    void     flush(world& w, container::index index, uint16_t endpoint);
    void     rollback(world& w, container::index index, uint16_t endpoint);

    // for trading
    bool pickup_force(world& w, container::index start, uint16_t item, uint16_t amount, bool unlock);
    void place_force(world& w, container::index start, uint16_t item, uint16_t amount, bool unlock);
}
