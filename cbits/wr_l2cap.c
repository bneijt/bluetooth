#include "wr_bluetooth.h"
#include "wr_l2cap.h"

wr_bdaddr_t *wr_sockaddr_l2_get_bdaddr(wr_bdaddr_t *dst, const sockaddr_l2_t *const src) {
    return to_wr_bdaddr(dst, &src->l2_bdaddr);
}

void wr_sockaddr_l2_set_bdaddr(sockaddr_l2_t *sa, const wr_bdaddr_t *const ba) {
    from_wr_bdaddr(&sa->l2_bdaddr, ba);
}