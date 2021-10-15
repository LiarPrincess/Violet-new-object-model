#ifndef objects_layout_h
#define objects_layout_h

#include <stdint.h>

/* ===================================== */
/* === Solution 1 (C1) - with struct === */
/* ===================================== */

typedef struct {
  void* _type;
  uint32_t _flags;
} C1_ObjectHeader;

typedef struct {
  C1_ObjectHeader _header;
} C1_Object;

typedef struct {
  C1_ObjectHeader _header;
//  var name: String // How?
  void* _base;
} C1_Type;

/* ==================================== */
/* === Solution 2 (C2) - with macro === */
/* ==================================== */

#define C2_HEADER \
  void* _type;\
  uint32_t _flags;

typedef struct {
  C2_HEADER
} C2_Object;

typedef struct {
  C2_HEADER
//  var name: String // How?
  void* _base;
} C2_Type;


#endif /* objects_layout_h */
