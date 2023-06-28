#pragma once

#include <cstdint>

struct world;

bool backpack_pickup(world& w, uint16_t item, uint16_t amount);
void backpack_place(world& w, uint16_t item, uint16_t amount);
uint16_t backpack_query(world& w, uint16_t item);
