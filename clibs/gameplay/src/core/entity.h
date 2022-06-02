#pragma once

#include <stdint.h>

struct entity {
	uint8_t x;
	uint8_t y;
	uint16_t prototype;
	uint8_t direction;
};

struct chest {
	uint16_t container;
};

struct assembling {
	uint16_t recipe;
	uint16_t fluidbox_in;
	uint16_t fluidbox_out;
	uint16_t container;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};

struct laboratory {
	uint16_t tech;
	uint16_t container;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};

struct inserter {
	uint16_t input_container;
	uint16_t output_container;
	uint16_t hold_item;
	uint16_t hold_amount;
	uint16_t progress;
	uint8_t status;
};

struct capacitance {
	uint32_t shortage;
	uint8_t network;
};

struct burner {
	uint16_t recipe;
	uint16_t container;
	uint16_t progress;
};

struct chimney {
	uint16_t recipe;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};

struct consumer {
	uint8_t low_power;
};

struct generator {};

struct solar_panel {};

struct accumulator {};

struct pole {};

struct power {};

struct fluidbox {
	uint16_t fluid;
	uint16_t id;
};

struct fluidboxes {
	struct fluidbox in[4];
	struct fluidbox out[3];
};

struct pump {};

struct mining {};

struct road {
	uint16_t road_type;
	uint16_t coord;
};

struct station {
	uint16_t id;
	uint16_t coord;
};

struct save_fluidflow {
	uint16_t fluid;
	uint16_t id;
	uint32_t volume;
};

template <typename T> struct component {};

template <> struct component<entity> {
	static inline const int id = 1;
	static inline const char name[] = "entity";
};

template <> struct component<chest> {
	static inline const int id = 2;
	static inline const char name[] = "chest";
};

template <> struct component<assembling> {
	static inline const int id = 3;
	static inline const char name[] = "assembling";
};

template <> struct component<laboratory> {
	static inline const int id = 4;
	static inline const char name[] = "laboratory";
};

template <> struct component<inserter> {
	static inline const int id = 5;
	static inline const char name[] = "inserter";
};

template <> struct component<capacitance> {
	static inline const int id = 6;
	static inline const char name[] = "capacitance";
};

template <> struct component<burner> {
	static inline const int id = 7;
	static inline const char name[] = "burner";
};

template <> struct component<chimney> {
	static inline const int id = 8;
	static inline const char name[] = "chimney";
};

template <> struct component<consumer> {
	static inline const int id = 9;
	static inline const char name[] = "consumer";
};

template <> struct component<generator> {
	static inline const int id = 10;
	static inline const char name[] = "generator";
};

template <> struct component<solar_panel> {
	static inline const int id = 11;
	static inline const char name[] = "solar_panel";
};

template <> struct component<accumulator> {
	static inline const int id = 12;
	static inline const char name[] = "accumulator";
};

template <> struct component<pole> {
	static inline const int id = 13;
	static inline const char name[] = "pole";
};

template <> struct component<power> {
	static inline const int id = 14;
	static inline const char name[] = "power";
};

template <> struct component<fluidbox> {
	static inline const int id = 15;
	static inline const char name[] = "fluidbox";
};

template <> struct component<fluidboxes> {
	static inline const int id = 16;
	static inline const char name[] = "fluidboxes";
};

template <> struct component<pump> {
	static inline const int id = 17;
	static inline const char name[] = "pump";
};

template <> struct component<mining> {
	static inline const int id = 18;
	static inline const char name[] = "mining";
};

template <> struct component<road> {
	static inline const int id = 19;
	static inline const char name[] = "road";
};

template <> struct component<station> {
	static inline const int id = 20;
	static inline const char name[] = "station";
};

template <> struct component<save_fluidflow> {
	static inline const int id = 21;
	static inline const char name[] = "save_fluidflow";
};
