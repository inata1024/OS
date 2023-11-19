#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

list_entry_t pra_list_head;

/*
	基于stack实现的LRU，将每次访存的page提升至栈顶(head->next)，swap victim选择栈底(head->prev)
	数据结构使用链表，缺页时，与FIFO相同，将分配的page放到链表head之后。
	为记录所有内存访问，缺页处理最后，将其余所有页全部设为PTE_R=0,PTE_W=1（保留状态），这样会导致其他所有页在之后的访问异常
	在do_pgfault中，加入对PTE_R=0,PTE_W=1异常的处理。此时需要将出错的page提升至栈顶，即使用swap_in=-1调用swap_map_swappable,
	然后将它的perm恢复正常（即vma的perm），其余所有页全部设为PTE_R=0,PTE_W=1
    需要注意的是，修改pte后需要刷新tlb，否则cpu看到的仍是修改前的pte
	
*/

/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_lru_init_mm(struct mm_struct *mm)
{     
	list_init(&pra_list_head);
	mm->sm_priv = &pra_list_head;
	//cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
	return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
//为了保持sm结构体，将正常访问页时提升页至栈顶的操作写到这里，条件是第四个参数swap_in=-1;
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{

	//将其他页全部设为PTE_R=0,PTE_W=1
	list_entry_t *curr=(list_entry_t*) mm->sm_priv;
	while (1) {
		curr = list_prev(curr);
        if(curr == (list_entry_t*) mm->sm_priv)
            break;
		struct Page* pg = le2page(curr, pra_page_link);
		pte_t *ptep = get_pte(mm->pgdir, pg->pra_vaddr, 0);
		cprintf("page addr:%x\n",pg->pra_vaddr);
		*ptep = *ptep | PTE_W;
		*ptep = *ptep & ~PTE_R;
    }
    //刷新TLB
    tlb_invalidate(mm->pgdir, addr);
	
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
	assert(entry != NULL && head != NULL);
	//若是提升page，先将原有的entry从list中删去
	if(swap_in == -1){
		list_del(entry);
	}

    //加入list顶端
    list_add(head, entry);


    //打印链表信息
    cprintf("-----------\n");
	curr=(list_entry_t*) mm->sm_priv;
	while (1) {
		curr = list_prev(curr);
        if(curr == (list_entry_t*) mm->sm_priv)
            break;
		struct Page* pg = le2page(curr, pra_page_link);
        //发生页交换后，由于pg->pra_vaddr在调用此函数后才更新，所以会打印出被驱逐页的addr
		pte_t *ptep = get_pte(mm->pgdir, pg->pra_vaddr, 0);
		cprintf("page addr:%x  R:%d  W:%d\n",pg->pra_vaddr,*ptep & PTE_R,*ptep & PTE_W);
    }

    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
	list_entry_t *head=(list_entry_t*) mm->sm_priv;
	assert(head != NULL);
	assert(in_tick==0);
	/* Select the victim */
	//(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
	//(2)  set the addr of addr of this page to ptr_page
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
		//删去栈底的entry
        list_del(entry);
		//ptr_page返回entry对应的page
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
	
	
    return 0;
}

static int
_lru_check_swap(void) {
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);

    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);

    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);

    //---------
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    //assert(pgfault_num==6);
    assert(pgfault_num==5);

    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    //assert(pgfault_num==7);
    assert(pgfault_num==5);

    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    //assert(pgfault_num==8);
    assert(pgfault_num==6);

    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    //assert(pgfault_num==9);
    assert(pgfault_num==7);


    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    //assert(pgfault_num==10);
    assert(pgfault_num==8);

    cprintf("write Virt Page a in fifo_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    //assert(pgfault_num==11);
    assert(pgfault_num==9);

    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru =
{
	.name            = "lru swap manager",
     .init            = &_lru_init,
	  .init_mm         = &_lru_init_mm,
	   .tick_event      = &_lru_tick_event,
		.map_swappable   = &_lru_map_swappable,
		 .set_unswappable = &_lru_set_unswappable,
		  .swap_out_victim = &_lru_swap_out_victim,
		   .check_swap      = &_lru_check_swap,
};



