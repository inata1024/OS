//#include<stdlib.h>
#include<assert.h>
#include<stdio.h>
#include<string.h>
#include<pmm.h>

//此时只有Page->ref, Page->flags有用
struct buddy2{
    struct Page* base;
    unsigned size;
    unsigned *longest;
};

#define LEFT_LEAF(index) ((index)*2+1)
#define RIGHT_LEAF(index) ((index)*2+2)
#define PARENT(index) (((index)+1)/2-1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a,b) ((a)>(b)?(a):(b))


//返回比size大的最小2的乘方
static unsigned fixsize(unsigned size){
    size |= size >> 1;
    size |= size >> 2;
    size |= size >> 4;
    size |= size >> 8;
    size |= size >> 16;
    return size+1;    
}

//初始化一个管理size个单位内存的系统
//其中buddy结构体在pmm.c中分配了物理内存
//不需要记录nr_free
static void
buddy_init_memmap(struct Page *base, size_t size) {
    //buddy结构体结束后是一个unsigned数组
    buddy->longest = (unsigned *)((unsigned long)(buddy + sizeof(struct buddy2)));
    //地址需要对齐
    buddy->longest = (unsigned *)((((unsigned long)buddy->longest >> 4) + 1) << 4);
    unsigned node_size;
    int i;

    // if(size < 1 || !IS_POWER_OF_2(size))
    //     return NULL;

    //longest数组的长度为2*size-1，再加上一个unsigned类型的size
    buddy->size = size;
    buddy->base = base;
    node_size = size * 2;
    //初始化longest，即二叉树每个节点对应的内存大小
    for(i = 0;i < 2 * size - 1;i++)
    {
        if(IS_POWER_OF_2(i+1))
        {
            cprintf("%d\n",node_size);
            node_size /= 2;
        }
        buddy->longest[i] = node_size;
    }

    //设置Page->ref, Page->flags
    struct Page *p = base;
    for (; p != base + size; p ++) {
        assert(PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    SetPageProperty(base);
}

// void buddy2_destory(struct buddy2* self){
//     FREE(self);//没有stdlib，没法free
// }

//分配size个单位的内存
int buddy2_alloc(struct buddy2* self, int size){
    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    if(self == NULL)
        return -1;

    //规则化size
    if(size <= 0)
        size = 1;
    else if(!IS_POWER_OF_2(size))
        size = fixsize(size);

    //没有这么多空间的情况
    if(self->longest[index] < size)
        return -1;

    //从根节点开始，不断选择足够大的子节点
    for(node_size = self->size;node_size != size;node_size /= 2){
        if(self->longest[LEFT_LEAF(index)] >= size)
            index = LEFT_LEAF(index);
        else   
            index = RIGHT_LEAF(index);
    }

    self->longest[index] = 0;
    //以叶节点为单位的offset
    offset = (index + 1) * node_size - self->size;

    //更新祖先节点的可用空间
    while(index){
        index = PARENT(index);
        self->longest[index] = MAX(self->longest[LEFT_LEAF(index)],self->longest[RIGHT_LEAF(index)]);
    }

    return offset;
}

void buddy2_free(struct buddy2* self, int offset){
    unsigned node_size, index = 0;
    unsigned left_longest, right_longest;

    assert(self && offset >= 0 && offset < self->size);

    node_size = 1;
    index = offset + self->size - 1;

    //从叶节点开始搜索，找到第一个longest为0的节点
    for(; self->longest[index]; index = PARENT(index)){
        node_size *= 2;
        if(index == 0)
            return;
    }

    //恢复这个节点的size
    self->longest[index] = node_size;

    //合并祖先节点
    while(index){
        index = PARENT(index);
        node_size *= 2;

        left_longest = self->longest[LEFT_LEAF(index)];
        right_longest = self->longest[RIGHT_LEAF(index)];

        if(left_longest + right_longest == node_size)
            self->longest[index] = node_size;
        else   
            self->longest[index] = MAX(left_longest,right_longest);
    }
}

int buddy2_size(struct buddy2* self, int offset) {
  unsigned node_size, index = 0;

  assert(self && offset >= 0 && offset < self->size);

  node_size = 1;
  for (index = offset + self->size - 1; self->longest[index] ; index = PARENT(index))
    node_size *= 2;

  return node_size;
}

void buddy2_dump(struct buddy2* self) {
  int i,j;
  unsigned node_size, offset;
 
  node_size = self->size * 2;
  //开始dump
  cprintf("--------------------------------\n");

  for (i = 0; i < 2 * self->size - 1; ++i) {
    if ( IS_POWER_OF_2(i+1) )
      node_size /= 2;

    if ( self->longest[i] == 0 ) {
      //仅分配一个叶节点的情况
      if (i >=  self->size - 1) {
        cprintf("[%d, %d) size = 1\n", i - self->size + 1, i - self->size + 2);
        //canvas[i - self->size + 1] = '*';
      }
      else if (self->longest[LEFT_LEAF(i)] && self->longest[RIGHT_LEAF(i)]) {
        offset = (i+1) * node_size - self->size;
        cprintf("[%d, %d) size = %d\n", offset, offset + node_size, node_size);
        // for (j = offset; j < offset + node_size; ++j)
        //   canvas[j] = '*';
      }
    }
  }
  //结束dump
  cprintf("--------------------------------\n");
}

static void
buddy_init(void) {}

static struct Page *
buddy_alloc_pages(size_t n) {
    int offset = buddy2_alloc(buddy, n);
    struct Page *page = buddy->base + offset;
    ClearPageProperty(page);
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    SetPageProperty(base);

    buddy2_free(buddy, (int)(base - buddy->base));
}

static size_t
buddy_nr_free_pages(void) {
    return buddy->longest[0];
}

static void
buddy_check(void) {
    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = p3 = NULL;
    // assert((p0 = alloc_pages(31)) != NULL);
    // buddy2_dump(buddy);
    // assert((p1 = alloc_pages(255)) != NULL);
    // buddy2_dump(buddy);
    // assert((p2 = alloc_pages(513)) != NULL);
    // buddy2_dump(buddy);

    // assert(p0 != p1 && p0 != p2 && p1 != p2);
    // assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    // assert(page2pa(p0) < npage * PGSIZE);
    // assert(page2pa(p1) < npage * PGSIZE);
    // assert(page2pa(p2) < npage * PGSIZE);

    // free_pages(p0, 31);
    // buddy2_dump(buddy);
    // free_pages(p1, 255);
    // buddy2_dump(buddy);
    // free_pages(p2, 513);
    // buddy2_dump(buddy);

    assert((p0 = alloc_pages(70)) != NULL);
    buddy2_dump(buddy);
    assert((p1 = alloc_pages(35)) != NULL);
    buddy2_dump(buddy);
    assert((p2 = alloc_pages(80)) != NULL);
    buddy2_dump(buddy);

    free_pages(p0, 70);
    buddy2_dump(buddy);
    assert((p3 = alloc_pages(60)) != NULL);
    buddy2_dump(buddy);
    free_pages(p1, 35);
    buddy2_dump(buddy);
    free_pages(p3, 60);
    buddy2_dump(buddy);
    free_pages(p2, 80);

}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
