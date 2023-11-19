#ifndef __BUDDY2_H_H
#define __BUDDY2_H_H

// #include <stdlib.h>

extern const struct pmm_manager buddy_pmm_manager;
struct buddy2;
struct buddy2* buddy2_new(int size);
void  buddy2_destory(struct buddy2* self);

int buddy2_alloc(struct buddy2* self, int size);
void buddy2_free(struct buddy2* self, int offset);

int buddy2_size(struct buddy2* self, int offset);
void buddy2_dump(struct buddy2* self);



#endif