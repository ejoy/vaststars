#ifndef vaststars_entity_h
#define vaststars_entity_h

struct entity {
	unsigned short coord;
	unsigned short prototype;
	unsigned char dir;
};

struct capacitance {
	float shortage;
};

struct bunker {
	int type;
	float number;
};

#define COMPONENT_CAPACITANCE 1

#define TAG_CONSUMER 2
#define TAG_GENERATOR 3
#define TAG_ACCUMULATOR 4

#define COMPONENT_ENTITY 5
#define COMPONENT_BUNKER 6

struct station {
	unsigned short id;
	unsigned short coord;
};

#define TAG_ROAD 7
#define COMPONENT_STATION 8

#endif