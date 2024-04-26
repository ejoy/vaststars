#pragma once

#include <assert.h>

#include <memory>

template <typename T, std::size_t N = 256>
class queue {
public:
    typedef T value_type;
    typedef value_type* pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;
    static inline const size_t chunk_size = N;
    struct chunk_type {
        value_type values[N];
        chunk_type* next;
    };
    struct chunk_index {
        chunk_type* chunk;
        std::size_t pos;
        chunk_index(chunk_type* chunk)
            : chunk(chunk)
            , pos(0) {}
        chunk_index(const chunk_index& rhs)
            : chunk(rhs.chunk)
            , pos(rhs.pos) {}
        bool operator==(const chunk_index& rhs) const {
            return chunk == rhs.chunk && pos == rhs.pos;
        }
        reference get() {
            return chunk->values[pos];
        }
        const_reference get() const {
            return chunk->values[pos];
        }
    };
    struct iterator {
        bool operator==(const iterator& rhs) const {
            return index == rhs.index;
        }
        bool operator!=(const iterator& rhs) const {
            return !(index == rhs.index);
        }
        iterator& operator++() {
            if (++index.pos == N) {
                index.chunk = index.chunk->next;
                index.pos   = 0;
            }
            return *this;
        }
        reference operator*() {
            return index.get();
        }
        const_reference operator*() const {
            return index.get();
        }
        chunk_index index;
    };

public:
    queue()
        : front_(new chunk_type)
        , back_(front_) {
        assert(empty());
    }
    ~queue() {
        for (;;) {
            if (front_.chunk == back_.chunk) {
                delete front_.chunk;
                break;
            }
            chunk_type* o = front_.chunk;
            front_.chunk  = front_.chunk->next;
            delete o;
        }
    }
    queue(const queue&)            = delete;
    queue& operator=(const queue&) = delete;

    queue(queue&& o)
        : front_(o.front_)
        , back_(o.back_) {
        o.front_ = o.back_ = new chunk_type;
    }

    queue& operator=(queue&& o) {
        if (this != &o) {
            std::swap(*this, o);
        }
        return *this;
    };

    void push(value_type&& val) {
        new (&back()) T(::std::move(val));
        do_push();
    }
    void push(const_reference val) {
        new (&back()) T(val);
        do_push();
    }
    void pop() {
        assert(!empty());
        front().~T();
        do_pop();
    }
    bool try_pop(reference val) {
        if (empty())
            return false;
        val.~T();
        new (&val) T(front());
        pop();
        return true;
    }
    bool empty() const {
        return front_ == back_;
    }
    reference front() {
        return front_.get();
    }
    const_reference front() const {
        return front_.get();
    }
    reference back() {
        return back_.get();
    }
    const_reference back() const {
        return back_.get();
    }
    iterator begin() {
        return { front_ };
    }
    iterator end() {
        return { back_ };
    }
    iterator begin() const {
        return { front_ };
    }
    iterator end() const {
        return { back_ };
    }
    void clear() {
        for (;;) {
            if (front_.chunk == back_.chunk) {
                front_.pos = back_.pos = 0;
                break;
            }
            chunk_type* o = front_.chunk;
            front_.chunk  = front_.chunk->next;
            delete o;
        }
    }
    size_t size() const {
        size_t n = 0;
        for (chunk_type* o = front_.chunk; o != back_.chunk; o = o->next) {
            ++n;
        }
        return n * N + back_.pos - front_.pos;
    }
    void erase_end(iterator it) {
        auto o = it.index.chunk;
        if (o != back_.chunk) {
            o = o->next;
            for (;;) {
                if (o == back_.chunk) {
                    delete o;
                    break;
                } else {
                    auto next = o->next;
                    delete o;
                    o = next;
                }
            }
        }
        back_ = it.index;
    }

private:
    void do_push() {
        if (++back_.pos != N)
            return;
        chunk_type* o     = spare_chunk
                                ? spare_chunk.release()
                                : new chunk_type;
        back_.chunk->next = o;
        back_             = { o };
    }
    void do_pop() {
        if (++front_.pos != N)
            return;
        chunk_type* o = front_.chunk;
        front_        = { o->next };
        spare_chunk.reset(o);
    }

private:
    chunk_index front_;
    chunk_index back_;
    std::unique_ptr<chunk_type> spare_chunk;
};
