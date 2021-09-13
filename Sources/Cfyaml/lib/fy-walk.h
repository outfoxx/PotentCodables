/*
 * fy-walk.h - walker  internal header file
 *
 * Copyright (c) 2021 Pantelis Antoniou <pantelis.antoniou@konsulko.com>
 *
 * SPDX-License-Identifier: MIT
 */
#ifndef FY_WALK_H
#define FY_WALK_H

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdarg.h>

#include <libfyaml.h>

#include "fy-ctype.h"
#include "fy-utf8.h"
#include "fy-list.h"
#include "fy-typelist.h"
#include "fy-types.h"
#include "fy-diag.h"
#include "fy-dump.h"
#include "fy-docstate.h"
#include "fy-accel.h"
#include "fy-doc.h"
#include "fy-token.h"

struct fy_walk_result {
	struct list_head node;
	struct fy_node *fyn;
};
FY_TYPE_FWD_DECL_LIST(walk_result);
FY_TYPE_DECL_LIST(walk_result);

void fy_walk_result_free(struct fy_walk_result *fwr);
void fy_walk_result_list_free(struct fy_walk_result_list *results);

enum fy_path_expr_type {
	fpet_none,
	/* ypath */
	fpet_root,		/* /^ or / at the beginning of the expr */
	fpet_this,		/* /. */
	fpet_parent,		/* /.. */
	fpet_every_child,	// /* every immediate child
	fpet_every_child_r,	// /** every recursive child
	fpet_filter_collection,	/* match only collection (at the end only) */
	fpet_filter_scalar,	/* match only scalars (leaves) */
	fpet_filter_sequence,	/* match only sequences */
	fpet_filter_mapping,	/* match only mappings */
	fpet_seq_index,
	fpet_map_key,		/* complex map key (quoted, flow seq or map) */
	fpet_seq_slice,
	fpet_alias,

	fpet_multi,		/* merge results of children */
	fpet_chain,		/* children move in sequence */
	fpet_logical_or,	/* first non null result set */
	fpet_logical_and,	/* the last non null result set */
};

extern const char *path_expr_type_txt[];

static inline bool fy_path_expr_type_is_valid(enum fy_path_expr_type type)
{
	return type >= fpet_root && type <= fpet_logical_and;
}

static inline bool fy_path_expr_type_is_single_result(enum fy_path_expr_type type)
{
	return type == fpet_root ||
	       type == fpet_this ||
	       type == fpet_parent ||
	       type == fpet_map_key ||
	       type == fpet_seq_index ||
	       type == fpet_alias ||
	       type == fpet_filter_collection ||
	       type == fpet_filter_scalar ||
	       type == fpet_filter_sequence ||
	       type == fpet_filter_mapping;
}

static inline bool fy_path_expr_type_is_parent(enum fy_path_expr_type type)
{
	return type == fpet_multi ||
	       type == fpet_chain ||
	       type == fpet_logical_or ||
	       type == fpet_logical_and;
}

FY_TYPE_FWD_DECL_LIST(path_expr);
struct fy_path_expr {
	struct list_head node;
	struct fy_path_expr *parent;
	struct fy_path_expr_list children;
	enum fy_path_expr_type type;
	struct fy_token *fyt;
};
FY_TYPE_DECL_LIST(path_expr);

const struct fy_mark *fy_path_expr_start_mark(struct fy_path_expr *expr);
const struct fy_mark *fy_path_expr_end_mark(struct fy_path_expr *expr);

struct fy_path_parser {
	struct fy_path_parse_cfg cfg;
	struct fy_reader reader;
	struct fy_token_list queued_tokens;
	enum fy_token_type last_queued_token_type;
	bool stream_start_produced;
	bool stream_end_produced;
	bool stream_error;
	int token_activity_counter;

	/* operator stack */
	unsigned int operator_top;
	unsigned int operator_alloc;
	struct fy_token **operators;
	struct fy_token *operators_static[16];

	/* operand stack */
	unsigned int operand_top;
	unsigned int operand_alloc;
	struct fy_path_expr **operands;
	struct fy_path_expr *operands_static[16];

	/* to avoid allocating */
	struct fy_path_expr_list expr_recycle;
	bool suppress_recycling;
};

struct fy_path_expr *fy_path_expr_alloc(void);
/* fy_path_expr_free is declared in libfyaml.h */
// void fy_path_expr_free(struct fy_path_expr *expr);

void fy_path_parser_setup(struct fy_path_parser *fypp, const struct fy_path_parse_cfg *pcfg);
void fy_path_parser_cleanup(struct fy_path_parser *fypp);
int fy_path_parser_open(struct fy_path_parser *fypp,
			struct fy_input *fyi, const struct fy_reader_input_cfg *icfg);
void fy_path_parser_close(struct fy_path_parser *fypp);

struct fy_token *fy_path_scan(struct fy_path_parser *fypp);

struct fy_path_expr *fy_path_parse_expression(struct fy_path_parser *fypp);

void fy_path_expr_dump(struct fy_path_expr *expr, struct fy_diag *diag, enum fy_error_type errlevel, int level, const char *banner);

int fy_path_expr_execute(struct fy_diag *diag, struct fy_path_expr *expr,
			 struct fy_walk_result_list *results, struct fy_node *fyn);

struct fy_path_exec {
	struct fy_path_exec_cfg cfg;
	struct fy_walk_result_list results;
	struct fy_node *fyn_start;
};

int fy_path_exec_setup(struct fy_path_exec *fypx, const struct fy_path_exec_cfg *xcfg);
void fy_path_exec_cleanup(struct fy_path_exec *fypx);

#endif
