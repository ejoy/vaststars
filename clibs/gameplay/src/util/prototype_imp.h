#include <lua.h>
 
typedef float float_pt;
typedef int int_pt;
typedef int bool_pt;
typedef const char * string_pt;
typedef unsigned int uint_pt;
typedef lua_Integer int64_pt;
 
struct prototype_cache;
struct prototype_context {
	struct prototype_cache *c;
	int id;
};
 
#ifndef PROTOTYPE_IMPLEMENTATION
 
#define PROTOTYPE(name, type) type##_pt pt_##name(struct prototype_context *ctx);
 
#else
 
#include <stddef.h>
 
#define CACHE_SLOTS 1021
 
union cache_value {
	int d;
	unsigned int u;
	float f;
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
#define DEFAULT_uint 0
#define DEFAULT_int64 0
 
#define ID_float 0
#define ID_int 1
#define ID_bool 2
#define ID_string 3
#define ID_uint 4
#define ID_int64 5
 
#define RETURN_float_float(v) (v)
#define RETURN_float_int(v) DEFAULT_int
#define RETURN_float_bool(v) DEFAULT_bool
#define RETURN_float_string(v) DEFAULT_string
#define RETURN_float_uint(v) DEFAULT_uint
#define RETURN_float_int64(v) DEFAULT_int64
 
#define RETURN_int_float(v) DEFAULT_float
#define RETURN_int_int(v) (v)
#define RETURN_int_bool(v) DEFAULT_bool
#define RETURN_int_string(v) DEFAULT_string
#define RETURN_int_uint(v) DEFAULT_uint
#define RETURN_int_int64(v) DEFAULT_int64
 
#define RETURN_bool_float(v) DEFAULT_float
#define RETURN_bool_int(v) DEFAULT_int
#define RETURN_bool_bool(v) (v)
#define RETURN_bool_string(v) DEFAULT_string
#define RETURN_bool_uint(v) DEFAULT_uint
#define RETURN_bool_int64(v) DEFAULT_int64
 
#define RETURN_string_float(v) DEFAULT_float
#define RETURN_string_int(v) DEFAULT_int
#define RETURN_string_bool(v) DEFAULT_bool
#define RETURN_string_string(v) (v)
#define RETURN_string_uint(v) DEFAULT_uint
#define RETURN_string_int64(v) DEFAULT_int64
 
#define RETURN_uint_float(v) DEFAULT_float
#define RETURN_uint_int(v) DEFAULT_int
#define RETURN_uint_bool(v) DEFAULT_bool
#define RETURN_uint_string(v) DEFAULT_string
#define RETURN_uint_uint(v) (v)
#define RETURN_uint_int64(v) DEFAULT_int64
 
#define RETURN_int64_float(v) DEFAULT_float
#define RETURN_int64_int(v) DEFAULT_int
#define RETURN_int64_bool(v) DEFAULT_bool
#define RETURN_int64_string(v) DEFAULT_string
#define RETURN_int64_uint(v) DEFAULT_uint
#define RETURN_int64_int64(v) (v)
 
static inline int
inthash(unsigned int p) {
	int h = (2654435761 * p) % CACHE_SLOTS;
	return h;
}
 
static lua_Number read_float_lua(lua_State *L, struct prototype_cache *c, int id, const char *name);
static lua_Integer read_int_lua(lua_State *L, struct prototype_cache *c, int id, const char *name);
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
		t.v.f = (float)read_float_lua(L, c, cid & 0xffff, name);
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
		t.v.d = (int)read_int_lua(L, c, cid & 0xffff, name);
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
		p.d[0] = s->v.u;
		p.d[1] = s[1].v.u;
	} else {
		p.p = read_string_lua(L, c, cid & 0xffff, name);
		s->k = s[1].k = cid;
		s->v.u = p.d[0];
		s[1].v.u = p.d[1];
	}
	return p.p;
}
 
static inline int_pt
read_uint_(lua_State *L, struct prototype_cache *c, unsigned int cid, const char *name) {
	struct cache_slot *s = &c->s[inthash(cid)];
	if (s->k == cid)
		return s->v.u;
	else {
		struct cache_slot t;
		t.k = cid;
		t.v.u = (unsigned int)read_int_lua(L, c, cid & 0xffff, name);
		*s = t;
		return t.v.u;
	}
}
 
static inline int64_pt
read_int64_(lua_State *L, struct prototype_cache *c, unsigned int cid, const char *name) {
	struct cache_slot *s = &c->s[inthash(cid) & ~1];
	union int64 {
		unsigned int d[2];
		lua_Integer p;
	} p;
	if (s->k == cid && s[1].k == cid) {
		p.d[0] = s->v.u;
		p.d[1] = s[1].v.u;
	} else {
		p.p = read_int_lua(L, c, cid & 0xffff, name);
		s->k = s[1].k = cid;
		s->v.u = p.d[0];
		s[1].v.u = p.d[1];
	}
	return p.p;
}
 
#define PROTOTYPE(name, type)	\
type##_pt pt_##name(struct prototype_context *ctx) {	\
	struct prototype_cache *c = ctx->c;	\
	lua_State *L = c->L;	\
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
	case ID_uint:	\
		return RETURN_uint_##type(read_uint_(L, c, cid, #name));	\
	case ID_int64:	\
		return RETURN_int64_##type(read_int64_(L, c, cid, #name));	\
	default:	\
		return DEFAULT_##type;	\
	}	\
}
 
#endif
