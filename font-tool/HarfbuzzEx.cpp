#include "hb-open-type-private.hh"
#include "hb-ot-layout-private.hh"

#include "hb-ot-layout-gdef-table.hh"
#include "hb-ot-layout-gsub-table.hh"
#include "hb-ot-layout-gpos-table.hh"
#include "hb-ot-layout-jstf-table.hh" // Just so we compile it; unused otherwise.

#include "HarfbuzzEx.h"


/**
 * hb_ot_layout_lookup_get_type:
 **/
unsigned int
hb_ot_layout_lookup_get_type (hb_face_t    *face,
                              hb_tag_t      table_tag,
                              unsigned int  lookup_index)
{
    switch (table_tag)
    {
        case HB_OT_TAG_GSUB:
        {
            const OT::SubstLookup& l = hb_ot_layout_from_face (face)->gsub->get_lookup (lookup_index);
            return l.get_type();
        }
        case HB_OT_TAG_GPOS:
        {
            const OT::PosLookup& l = hb_ot_layout_from_face (face)->gpos->get_lookup (lookup_index);
            return l.get_type();
        }
        default :
        {
            return -1;
        }
    }
}
    
/**
 * hb_ot_layout_lookup_get_flag:
 **/
uint16_t
hb_ot_layout_lookup_get_flag (hb_face_t    *face,
                              hb_tag_t      table_tag,
                              unsigned int  lookup_index)
{
    switch (table_tag)
    {
        case HB_OT_TAG_GSUB:
        {
            const OT::SubstLookup& l = hb_ot_layout_from_face (face)->gsub->get_lookup (lookup_index);
            return l.get_props() & 0xFFFF;
        }
        case HB_OT_TAG_GPOS:
        {
            const OT::PosLookup& l = hb_ot_layout_from_face (face)->gpos->get_lookup (lookup_index);
            return l.get_props() & 0xFFFF;
        }
        default :
        {
            return -1;
        }
    }
}
    
    
/**
 * hb_ot_layout_lookup_get_mark_filtering_set:
 **/
uint16_t
hb_ot_layout_lookup_get_mark_filtering_set (hb_face_t    *face,
                                            hb_tag_t      table_tag,
                                            unsigned int  lookup_index)
{
    switch (table_tag)
    {
        case HB_OT_TAG_GSUB:
        {
            const OT::SubstLookup& l = hb_ot_layout_from_face (face)->gsub->get_lookup (lookup_index);
            return l.get_props() >> 16;
        }
        case HB_OT_TAG_GPOS:
        {
            const OT::PosLookup& l = hb_ot_layout_from_face (face)->gpos->get_lookup (lookup_index);
            return l.get_props() >> 16;
        }
        default :
        {
            return -1;
        }
    }
}
    
/**
 * hb_ot_layout_lookup_get_mark_filtering_set:
 **/
unsigned int
hb_ot_layout_lookup_get_subtable_count (hb_face_t    *face,
                                        hb_tag_t      table_tag,
                                        unsigned int  lookup_index)
{
    switch (table_tag)
    {
        case HB_OT_TAG_GSUB:
        {
            const OT::SubstLookup& l = hb_ot_layout_from_face (face)->gsub->get_lookup (lookup_index);
            return l.get_subtable_count();
        }
        case HB_OT_TAG_GPOS:
        {
            const OT::PosLookup& l = hb_ot_layout_from_face (face)->gpos->get_lookup (lookup_index);
            return l.get_subtable_count();
        }
        default :
        {
            return -1;
        }
    }
}
    
    
hb_set_t *
hb_ot_layout_lookup_get_subtable_coverage (hb_face_t    *face,
                                           hb_tag_t      table_tag,
                                           unsigned int  lookup_index,
                                           unsigned int  subtable_index)
{
    switch (table_tag)
    {
        case HB_OT_TAG_GSUB:
        {
            const OT::SubstLookup& l = hb_ot_layout_from_face (face)->gsub->get_lookup (lookup_index);
            const OT::SubstLookupSubTable& sub = l.get_subtable(subtable_index);
            hb_set_t * glyphs = hb_set_create();
                
            OT::hb_add_coverage_context_t<hb_set_t> c (glyphs);
            OT::hb_add_coverage_context_t<hb_set_t>::return_t r = sub.dispatch(&c, l.get_type());
                
            if (!c.stop_sublookup_iteration (r))
                return glyphs;
            return NULL;
        }
        case HB_OT_TAG_GPOS:
        {
            const OT::PosLookup& l = hb_ot_layout_from_face (face)->gpos->get_lookup (lookup_index);
            const OT::PosLookupSubTable& sub = l.get_subtable(subtable_index);
            hb_set_t * glyphs = hb_set_create();
                
            OT::hb_add_coverage_context_t<hb_set_t> c (glyphs);
            OT::hb_add_coverage_context_t<hb_set_t>::return_t r = sub.dispatch(&c, l.get_type());
            if (!c.stop_sublookup_iteration (r))
                return glyphs;
            return NULL;
        }
        default :
        {
            return NULL;
        }
    }
}


