typedef float float_pt;
typedef int int_pt;
typedef int bool_pt;
typedef const char * string_pt;

struct prototype_cache;
struct prototype_context {
	lua_State *L;
	struct prototype_cache *c;
	int id;
};

#ifndef PROTOTYPE_IMPLEMENTATION

#define PROTOTYPE(name, type) type##_pt pt_##name(struct prototype_context *ctx);

#else

#include <stddef.h>
#include <lua.h>

#define CACHE_SLOTS 1021

union cache_value {
	int d;
	float f;
	unsigned int p;
};

struct cache_slot {
	unsigned int k;
	union cache_value v;
};

struct prototype_cache {
	struct cache_slot s[CACHE_SLOTS+1];
	lua_State *L;
	int last;
};

#ifndef __COUNTER__
#define __COUNTER__ __LINE__
#endif

#define DEFAULT_float 0
#define DEFAULT_int 0
#define DEFAULT_bool 0
#define DEFAULT_string NULL

#define ID_float 0
#define ID_int 1
#define ID_bool 2
#define ID_string 3

#define RETURN_float_float(v) (v)
#define RETURN_float_int(v) DEFAULT_int
#define RETURN_float_bool(v) DEFAULT_bool
#define RETURN_float_string(v) DEFAULT_string

#define RETURN_int_float(v) DEFAULT_float
#define RETURN_int_int(v) (v)
#define RETURN_int_bool(v) DEFAULT_bool
#define RETURN_int_string(v) DEFAULT_string

#define RETURN_bool_float(v) DEFAULT_float
#define RETURN_bool_int(v) DEFAULT_int
#define RETURN_bool_bool(v) (v)
#define RETURN_bool_string(v) DEFAULT_string

#define RETURN_string_float(v) DEFAULT_float
#define RETURN_string_int(v) DEFAULT_int
#define RETURN_string_bool(v) DEFAULT_bool
#define RETURN_string_string(v) (v)

static inline int
inthash(unsigned int p) {
	int h = (2654435761 * p) % CACHE_SLOTS;
	return h;
}

static float read_float_lua(lua_State *L, struct prototype_cache *c, int id, const char *name);
static int read_int_lua(lua_State *L, struct prototype_cache *c, int id, const char *name);
static int read_bool_lua(lua_State *L, struct prototype_cache *c, int id, const char *name);
static const char * read_string_lua(lua_State *L, struct prototype_cache *c, int id, const char *name);

static inline float_pt
read_float_(lua_State *L, struct prototype_cache *c, unsigned int cid, const char *name) {
	struct cache_slot *s = &c->s[inthash(cid)];
	if (s->k == cid)
		return s->v.f;
	else {
		struct cache_slot t;
		t.k = cid;
		t.v.f = read_float_lua(L, c, cid & 0xffff, name);
		*s = t;
		return t.v.f;
	}
}

static inline int_pt
read_int_(lua_State *L, struct prototype_cache *c, unsigned int cid, const char *name) {
	struct cache_slot *s = &c->s[inthash(cid)];
	if (s->k == cid)
		return s->v.d;
	else {
		struct cache_slot t;
		t.k = cid;
		t.v.d = read_int_lua(L, c, cid & 0xffff, name);
		*s = t;
		return t.v.d;
	}
}

static inline bool_pt
read_bool_(lua_State *L, struct prototype_cache *c, unsigned int cid, const char *name) {
	struct cache_slot *s = &c->s[inthash(cid)];
	if (s->k == cid)
		return s->v.d;
	else {
		struct cache_slot t;
		t.k = cid;
		t.v.d = read_bool_lua(L, c, cid & 0xffff, name);
		*s = t;
		return t.v.d;
	}
}

static inline string_pt
read_string_(lua_State *L, struct prototype_cache *c, unsigned int cid, const char *name) {
	struct cache_slot *s = &c->s[inthash(cid) & ~1];
	union pointer {
		unsigned int d[2];
		const char *p;
	} p;
	if (s->k == cid && s[1].k == cid) {
		p.d[0] = s->v.p;
		p.d[1] = s[1].v.p;
	} else {
		p.p = read_string_lua(L, c, cid & 0xffff, name);
		s->k = s[1].k = cid;
		s->v.p = p.d[0];
		s[1].v.p = p.d[1];
	}
	return p.p;
}

#define PROTOTYPE(name, type)	\
type##_pt pt_##name(struct prototype_context *ctx) {	\
	lua_State *L = ctx->L;	\
	struct prototype_cache *c = ctx->c;	\
	unsigned int cid = (__COUNTER__	<< 16) | ctx->id;	\
	switch (ID_##type) {	\
	case ID_float :	\
		return RETURN_float_##type(read_float_(L, c, cid, #name));	\
	case ID_int:	\
		return RETURN_int_##type(read_int_(L, c, cid, #name));	\
	case ID_bool:	\
		return RETURN_bool_##type(read_bool_(L, c, cid, #name));	\
	case ID_string:	\
		return RETURN_string_##type(read_string_(L, c, cid, #name));	\
	default:	\
		return DEFAULT_##type;	\
	}	\
}


#endif
