#pragma once

#include <stdint.h>
#include <assert.h>
#include <vector>

namespace roadnet {
    template <typename T>
    class dynarray {
    public:
        typedef       T                               value_type;
        typedef       T&                              reference;
        typedef const T&                              const_reference;
        typedef       T*                              pointer;
        typedef const T*                              const_pointer;
        typedef       T*                              iterator;
        typedef const T*                              const_iterator;
        typedef std::reverse_iterator<iterator>       reverse_iterator;
        typedef std::reverse_iterator<const_iterator> const_reverse_iterator;
        typedef size_t                                size_type;
        typedef ptrdiff_t                             difference_type;

        dynarray() {}
        dynarray(const dynarray& d) = delete;
        dynarray(dynarray&& d): data_(d.data_), size_(d.size_) { d.data_=nullptr; d.size_=0; }
        ~dynarray() { clear(); }
        dynarray& operator=(const dynarray& d) = delete;
        dynarray& operator=(dynarray&& d) = delete;

        void            reset(size_type n)            { clear(); if (n > 0) { data_ = new T[n]; size_ = n;  } }
        void            clear()                       { delete[] data_; size_ = 0; data_ = nullptr; }
        const_reference operator[](size_type n) const { assert(n < size_); return data_[n]; }
        reference       operator[](size_type n)       { assert(n < size_); return data_[n]; }
        size_type       size()                  const { return size_; }
        const_iterator  begin()                 const { return data_; }
        iterator        begin()                       { return data_; }
        const_iterator  end()                   const { return data_ + size_; }
        iterator        end()                         { return data_ + size_; }
    private:
        pointer   data_ = nullptr;
        size_type size_ = 0;
    };
}
