#ifndef HARFBUZZ_EX_H
#define HARFBUZZ_EX_H

#include <hb-ot.h>
//#include <hb-ot-layout.h>

HB_BEGIN_DECLS

/** return -1 if lookup not found **/
HB_EXTERN unsigned int
hb_ot_layout_lookup_get_type (hb_face_t    *face,
                              hb_tag_t      table_tag,
                              unsigned int  lookup_index);
    
HB_EXTERN uint16_t
hb_ot_layout_lookup_get_flag (hb_face_t    *face,
                              hb_tag_t      table_tag,
                              unsigned int  lookup_index);
    
HB_EXTERN uint16_t
hb_ot_layout_lookup_get_mark_filtering_set (hb_face_t    *face,
                                            hb_tag_t      table_tag,
                                            unsigned int  lookup_index);
    
HB_EXTERN unsigned int
hb_ot_layout_lookup_get_subtable_count (hb_face_t    *face,
                                        hb_tag_t      table_tag,
                                        unsigned int  lookup_index);
    
    
    
HB_EXTERN hb_set_t *
hb_ot_layout_lookup_get_subtable_coverage (hb_face_t    *face,
                                           hb_tag_t      table_tag,
                                           unsigned int  lookup_index,
                                           unsigned int  subtable_index);

    
HB_END_DECLS
#endif
