/*
 * fy-utils.c - Generic utilities for functionality that's missing
 *              from platforms.
 *
 * For now only used to implement memstream for Apple platforms.
 *
 * Copyright (c) 2019 Pantelis Antoniou <pantelis.antoniou@konsulko.com>
 *
 * SPDX-License-Identifier: MIT
 */
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "fy-utf8.h"
#include "fy-ctype.h"
#include "fy-utils.h"

#if defined(__APPLE__) && (_POSIX_C_SOURCE < 200809L)

/*
 * adapted from http://piumarta.com/software/memstream/
 *
 * Under the MIT license.
 */

/*
 * ----------------------------------------------------------------------------
 *
 * OPEN_MEMSTREAM(3)      BSD and Linux Library Functions     OPEN_MEMSTREAM(3)
 *
 * SYNOPSIS
 *     #include "memstream.h"
 *
 *     FILE *open_memstream(char **bufp, size_t *sizep);
 *
 * DESCRIPTION
 *     The open_memstream()  function opens a  stream for writing to  a buffer.
 *     The   buffer  is   dynamically  allocated   (as  with   malloc(3)),  and
 *     automatically grows  as required.  After closing the  stream, the caller
 *     should free(3) this buffer.
 *
 *     When  the  stream is  closed  (fclose(3))  or  flushed (fflush(3)),  the
 *     locations  pointed  to  by  bufp  and  sizep  are  updated  to  contain,
 *     respectively,  a pointer  to  the buffer  and  the current  size of  the
 *     buffer.  These values  remain valid only as long  as the caller performs
 *     no further output  on the stream.  If further  output is performed, then
 *     the  stream  must  again  be  flushed  before  trying  to  access  these
 *     variables.
 *
 *     A null byte  is maintained at the  end of the buffer.  This  byte is not
 *     included in the size value stored at sizep.
 *
 *     The stream's  file position can  be changed with fseek(3)  or fseeko(3).
 *     Moving the file position past the  end of the data already written fills
 *     the intervening space with zeros.
 *
 * RETURN VALUE
 *     Upon  successful  completion open_memstream()  returns  a FILE  pointer.
 *     Otherwise, NULL is returned and errno is set to indicate the error.
 *
 * CONFORMING TO
 *     POSIX.1-2008
 *
 * ----------------------------------------------------------------------------
 */

#ifndef min
#define min(X, Y) (((X) < (Y)) ? (X) : (Y))
#endif

struct memstream {
	size_t position;
	size_t size;
	size_t capacity;
	char *contents;
	char **ptr;
	size_t *sizeloc;
};

static int memstream_grow(struct memstream *ms, size_t minsize)
{
	size_t newcap;
	char *newcontents;

	newcap = ms->capacity * 2;
	while (newcap <= minsize + 1)
		newcap *= 2;
	newcontents = realloc(ms->contents, newcap);
	if (!newcontents)
		return -1;
	ms->contents = newcontents;
	memset(ms->contents + ms->capacity, 0, newcap - ms->capacity);
	ms->capacity = newcap;
	*ms->ptr = ms->contents;
	return 0;
}

static int memstream_read(void *cookie, char *buf, int count)
{
	struct memstream *ms = cookie;
	size_t n;

	n = min(ms->size - ms->position, (size_t)count);
	if (n < 1)
		return 0;
	memcpy(buf, ms->contents, n);
	ms->position += n;
	return n;
}

static int memstream_write(void *cookie, const char *buf, int count)
{
	struct memstream *ms = cookie;

	if (ms->capacity <= ms->position + (size_t)count &&
	    memstream_grow(ms, ms->position + (size_t)count) < 0)
		return -1;
	memcpy(ms->contents + ms->position, buf, count);
	ms->position += count;
	ms->contents[ms->position] = '\0';
	if (ms->size < ms->position)
		*ms->sizeloc = ms->size = ms->position;

	return count;
}

static fpos_t memstream_seek(void *cookie, fpos_t offset, int whence)
{
	struct memstream *ms = cookie;
	fpos_t pos= 0;

	switch (whence) {
	case SEEK_SET:
		pos = offset;
		break;
	case SEEK_CUR:
		pos = ms->position + offset;
		break;
	case SEEK_END:
		pos = ms->size + offset;
		break;
	default:
		errno= EINVAL;
		return -1;
	}
	if (pos >= (fpos_t)ms->capacity && memstream_grow(ms, pos) < 0)
		return -1;
	ms->position = pos;
	if (ms->size < ms->position)
		*ms->sizeloc = ms->size = ms->position;
	return pos;
}

static int memstream_close(void *cookie)
{
	struct memstream *ms = cookie;

	ms->size = min(ms->size, ms->position);
	*ms->ptr = ms->contents;
	*ms->sizeloc = ms->size;
	ms->contents[ms->size]= 0;
	/* ms->contents is what's returned */
	free(ms);
	return 0;
}

FILE *open_memstream(char **ptr, size_t *sizeloc)
{
	struct memstream *ms;
	FILE *fp;

	if (!ptr || !sizeloc) {
		errno= EINVAL;
		goto err_out;
	}

	ms = calloc(1, sizeof(struct memstream));
	if (!ms)
		goto err_out;

	ms->position = ms->size= 0;
	ms->capacity = 4096;
	ms->contents = calloc(ms->capacity, 1);
	if (!ms->contents)
		goto err_free_ms;
	ms->ptr = ptr;
	ms->sizeloc = sizeloc;
	fp= funopen(ms, memstream_read, memstream_write,
			memstream_seek, memstream_close);
	if (!fp)
		goto err_free_all;
	*ptr = ms->contents;
	*sizeloc = ms->size;
	return fp;

err_free_all:
	free(ms->contents);
err_free_ms:
	free(ms);
err_out:
	return NULL;
}

#endif /* __APPLE__ && _POSIX_C_SOURCE < 200809L */

bool fy_tag_uri_is_valid(const char *data, size_t len)
{
	const char *s, *e;
	int w, j, k, width, c;
	uint8_t octet, esc_octets[4];

	s = data;
	e = s + len;

	while ((c = fy_utf8_get(s, e - s, &w)) >= 0) {
		if (c != '%') {
			s += w;
			continue;
		}

		width = 0;
		k = 0;
		do {
			/* short URI escape */
			if ((e - s) < 3)
				return false;

			if (width > 0) {
				c = fy_utf8_get(s, e - s, &w);
				if (c != '%')
					return false;
			}

			s += w;

			octet = 0;

			for (j = 0; j < 2; j++) {
				c = fy_utf8_get(s, e - s, &w);
				if (!fy_is_hex(c))
					return false;
				s += w;

				octet <<= 4;
				if (c >= '0' && c <= '9')
					octet |= c - '0';
				else if (c >= 'a' && c <= 'f')
					octet |= 10 + c - 'a';
				else
					octet |= 10 + c - 'A';
			}
			if (!width) {
				width = fy_utf8_width_by_first_octet(octet);

				if (width < 1 || width > 4)
					return false;
				k = 0;
			}
			esc_octets[k++] = octet;

		} while (--width > 0);

		/* now convert to utf8 */
		c = fy_utf8_get(esc_octets, k, &w);

		if (c < 0)
			return false;
	}

	return true;
}

int fy_tag_handle_length(const char *data, size_t len)
{
	const char *s, *e;
	int c, w;

	s = data;
	e = s + len;

	c = fy_utf8_get(s, e - s, &w);
	if (c != '!')
		return -1;
	s += w;

	c = fy_utf8_get(s, e - s, &w);
	if (fy_is_ws(c))
		return s - data;
	/* if first character is !, empty handle */
	if (c == '!') {
		s += w;
		return s - data;
	}
	if (!fy_is_first_alpha(c))
		return -1;
	s += w;
	while (fy_is_alnum(c = fy_utf8_get(s, e - s, &w)))
		s += w;
	if (c == '!')
		s += w;

	return s - data;
}

int fy_tag_uri_length(const char *data, size_t len)
{
	const char *s, *e;
	int c, w, cn, wn, uri_length;

	s = data;
	e = s + len;

	while (fy_is_uri(c = fy_utf8_get(s, e - s, &w))) {
		cn = fy_utf8_get(s + w, e - (s + w), &wn);
		if ((fy_is_z(cn) || fy_is_blank(cn) || fy_is_any_lb(cn)) && fy_utf8_strchr(",}]", c))
			break;
		s += w;
	}
	uri_length = s - data;

	if (!fy_tag_uri_is_valid(data, uri_length))
		return -1;

	return uri_length;
}

int fy_tag_scan(const char *data, size_t len, struct fy_tag_scan_info *info)
{
	const char *s, *e;
	int total_length, handle_length, uri_length, prefix_length, suffix_length;
	int c, cn, w, wn;

	s = data;
	e = s + len;

	prefix_length = 0;

	/* it must start with '!' */
	c = fy_utf8_get(s, e - s, &w);
	if (c != '!')
		return -1;
	cn = fy_utf8_get(s + w, e - (s + w), &wn);
	if (cn == '<') {
		prefix_length = 2;
		suffix_length = 1;
	} else
		prefix_length = suffix_length = 0;

	if (prefix_length) {
		handle_length = 0; /* set the handle to '' */
		s += prefix_length;
	} else {
		/* either !suffix or !handle!suffix */
		/* we scan back to back, and split handle/suffix */
		handle_length = fy_tag_handle_length(s, e - s);
		if (handle_length <= 0)
			return -1;
		s += handle_length;
	}

	uri_length = fy_tag_uri_length(s, e - s);
	if (uri_length < 0)
		return -1;

	/* a handle? */
	if (!prefix_length && (handle_length == 0 || data[handle_length - 1] != '!')) {
		/* special case, '!', handle set to '' and suffix to '!' */
		if (handle_length == 1 && uri_length == 0) {
			handle_length = 0;
			uri_length = 1;
		} else {
			uri_length = handle_length - 1 + uri_length;
			handle_length = 1;
		}
	}
	total_length = prefix_length + handle_length + uri_length + suffix_length;

	if (total_length != (int)len)
		return -1;

	info->total_length = total_length;
	info->handle_length = handle_length;
	info->uri_length = uri_length;
	info->prefix_length = prefix_length;
	info->suffix_length = suffix_length;

	return 0;
}
