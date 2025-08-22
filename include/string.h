/**
 * @file string.h
 * @author Zack Bostock
 * @brief Prototypes for string/memory operations
 *
 * @copyright Copyright (c) 2025
 *
 */

#pragma once

#include <stddef.h>
#include <stdint.h>

/* ---------------------------- LITERAL CONSTANTS --------------------------- */
#ifndef NULL
#if __cplusplus >= 201103L
#define NULL nullptr
#elif defined(__cplusplus)
#define NULL 0L
#else
#define NULL ((void*)0)
#endif
#endif

/* -------------------------------- GLOBALS --------------------------------- */

/* --------------------------------- MACROS --------------------------------- */

/* --------------------------- INTERNALLY DEFINED --------------------------- */
void *memcpy  (void *__restrict dest, const void *__restrict src, size_t n);
void *memmove (void *dest, const void *src, size_t n);
void *memset  (void *s, int c, size_t n);
