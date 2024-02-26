#pragma once

#include <type_traits>
#include <string_view>

constexpr bool enum_is_valid(std::string_view name) noexcept {
    for (std::size_t i = name.size(); i > 0; --i) {
        const char c = name[i - 1];
        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_'))) {
            name.remove_prefix(i);
            break;
        }
    }
    if (name.size() > 0) {
        const char c = name[0];
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_')) {
            return true;
        }
    }
    return false;
}

template <typename E, E V>
constexpr auto enum_is_valid() noexcept {
#if __GNUC__ || __clang__
    return enum_is_valid({__PRETTY_FUNCTION__, sizeof(__PRETTY_FUNCTION__) - 2});
#elif _MSC_VER
    return enum_is_valid({__FUNCSIG__, sizeof(__FUNCSIG__) - 17});
#else
    static_assert(false, "Unsupported compiler");
#endif
}

template <typename E, std::size_t I = 0>
constexpr auto enum_count() noexcept {
#if defined(__clang__) && __clang_major__ >= 16
    constexpr E e = __builtin_bit_cast(E, static_cast<std::underlying_type_t<E>>(I));
#else
    constexpr E e = static_cast<E>(static_cast<std::underlying_type_t<E>>(I));
#endif
    if constexpr (!enum_is_valid<E, e>()) {
        return I;
    } else {
        return enum_count<E, I+1>();
    }
}

template <typename E>
static constexpr auto enum_count_v = enum_count<E>();
