//
//  TypefaceNames.m
//  tx-research
//
//  Created by Yuqing Jiang on 5/31/17.
//
//

#import "TypefaceNames.h"
#import "CharEncoding.h"

#include FT_SFNT_NAMES_H

typedef struct {
    const FT_UShort	platform_id;
    const FT_UShort	language_id;
    const char	lang[8];
} FtLanguage;

#define TT_LANGUAGE_DONT_CARE	0xffff

// Copy from fontconfig
static const FtLanguage   ftLanguages[] = {
    {  TT_PLATFORM_APPLE_UNICODE,	TT_LANGUAGE_DONT_CARE,		    "" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ENGLISH,		    "en" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_FRENCH,		    "fr" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GERMAN,		    "de" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ITALIAN,		    "it" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_DUTCH,		    "nl" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SWEDISH,		    "sv" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SPANISH,		    "es" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_DANISH,		    "da" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_PORTUGUESE,	    "pt" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_NORWEGIAN,	    "no" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_HEBREW,		    "he" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_JAPANESE,		    "ja" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ARABIC,		    "ar" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_FINNISH,		    "fi" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GREEK,		    "el" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ICELANDIC,	    "is" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MALTESE,		    "mt" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TURKISH,		    "tr" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_CROATIAN,		    "hr" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_CHINESE_TRADITIONAL,  "zh-tw" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_URDU,		    "ur" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_HINDI,		    "hi" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_THAI,		    "th" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KOREAN,		    "ko" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_LITHUANIAN,	    "lt" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_POLISH,		    "pl" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_HUNGARIAN,	    "hu" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ESTONIAN,		    "et" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_LETTISH,		    "lv" },
    /* {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SAAMISK, ??? */
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_FAEROESE,		    "fo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_FARSI,		    "fa" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_RUSSIAN,		    "ru" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_CHINESE_SIMPLIFIED,   "zh-cn" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_FLEMISH,		    "nl" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_IRISH,		    "ga" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ALBANIAN,		    "sq" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ROMANIAN,		    "ro" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_CZECH,		    "cs" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SLOVAK,		    "sk" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SLOVENIAN,	    "sl" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_YIDDISH,		    "yi" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SERBIAN,		    "sr" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MACEDONIAN,	    "mk" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_BULGARIAN,	    "bg" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_UKRAINIAN,	    "uk" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_BYELORUSSIAN,	    "be" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_UZBEK,		    "uz" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KAZAKH,		    "kk" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AZERBAIJANI,	    "az" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AZERBAIJANI_CYRILLIC_SCRIPT, "az" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AZERBAIJANI_ARABIC_SCRIPT,    "ar" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ARMENIAN,		    "hy" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GEORGIAN,		    "ka" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MOLDAVIAN,	    "mo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KIRGHIZ,		    "ky" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TAJIKI,		    "tg" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TURKMEN,		    "tk" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MONGOLIAN,	    "mo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MONGOLIAN_MONGOLIAN_SCRIPT,"mo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MONGOLIAN_CYRILLIC_SCRIPT, "mo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_PASHTO,		    "ps" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KURDISH,		    "ku" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KASHMIRI,		    "ks" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SINDHI,		    "sd" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TIBETAN,		    "bo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_NEPALI,		    "ne" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SANSKRIT,		    "sa" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MARATHI,		    "mr" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_BENGALI,		    "bn" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ASSAMESE,		    "as" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GUJARATI,		    "gu" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_PUNJABI,		    "pa" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ORIYA,		    "or" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MALAYALAM,	    "ml" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KANNADA,		    "kn" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TAMIL,		    "ta" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TELUGU,		    "te" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SINHALESE,	    "si" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_BURMESE,		    "my" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_KHMER,		    "km" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_LAO,		    "lo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_VIETNAMESE,	    "vi" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_INDONESIAN,	    "id" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TAGALOG,		    "tl" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MALAY_ROMAN_SCRIPT,   "ms" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MALAY_ARABIC_SCRIPT,  "ms" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AMHARIC,		    "am" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TIGRINYA,		    "ti" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GALLA,		    "om" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SOMALI,		    "so" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SWAHILI,		    "sw" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_RUANDA,		    "rw" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_RUNDI,		    "rn" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_CHEWA,		    "ny" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MALAGASY,		    "mg" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_ESPERANTO,	    "eo" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_WELSH,		    "cy" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_BASQUE,		    "eu" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_CATALAN,		    "ca" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_LATIN,		    "la" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_QUECHUA,		    "qu" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GUARANI,		    "gn" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AYMARA,		    "ay" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TATAR,		    "tt" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_UIGHUR,		    "ug" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_DZONGKHA,		    "dz" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_JAVANESE,		    "jw" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SUNDANESE,	    "su" },
    
#if 0  /* these seem to be errors that have been dropped */
    
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SCOTTISH_GAELIC },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_IRISH_GAELIC },
    
#endif
    
    /* The following codes are new as of 2000-03-10 */
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GALICIAN,		    "gl" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AFRIKAANS,	    "af" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_BRETON,		    "br" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_INUKTITUT,	    "iu" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_SCOTTISH_GAELIC,	    "gd" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_MANX_GAELIC,	    "gv" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_IRISH_GAELIC,	    "ga" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_TONGAN,		    "to" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GREEK_POLYTONIC,	    "el" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_GREELANDIC,	    "ik" },
    {  TT_PLATFORM_MACINTOSH,	TT_MAC_LANGID_AZERBAIJANI_ROMAN_SCRIPT,"az" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_SAUDI_ARABIA,	"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_IRAQ,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_EGYPT,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_LIBYA,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_ALGERIA,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_MOROCCO,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_TUNISIA,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_OMAN,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_YEMEN,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_SYRIA,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_JORDAN,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_LEBANON,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_KUWAIT,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_UAE,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_BAHRAIN,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_QATAR,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BULGARIAN_BULGARIA,	"bg" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CATALAN_SPAIN,		"ca" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHINESE_TAIWAN,		"zh-tw" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHINESE_PRC,		"zh-cn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHINESE_HONG_KONG,		"zh-hk" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHINESE_SINGAPORE,		"zh-sg" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHINESE_MACAU,		"zh-mo" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CZECH_CZECH_REPUBLIC,	"cs" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_DANISH_DENMARK,		"da" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GERMAN_GERMANY,		"de" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GERMAN_SWITZERLAND,	"de" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GERMAN_AUSTRIA,		"de" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GERMAN_LUXEMBOURG,		"de" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GERMAN_LIECHTENSTEI,	"de" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GREEK_GREECE,		"el" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_UNITED_STATES,	"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_UNITED_KINGDOM,	"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_AUSTRALIA,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_CANADA,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_NEW_ZEALAND,	"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_IRELAND,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_SOUTH_AFRICA,	"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_JAMAICA,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_CARIBBEAN,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_BELIZE,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_TRINIDAD,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_ZIMBABWE,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_PHILIPPINES,	"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_SPAIN_TRADITIONAL_SORT,"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_MEXICO,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_SPAIN_INTERNATIONAL_SORT,"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_GUATEMALA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_COSTA_RICA,	"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_PANAMA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_DOMINICAN_REPUBLIC,"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_VENEZUELA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_COLOMBIA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_PERU,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_ARGENTINA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_ECUADOR,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_CHILE,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_URUGUAY,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_PARAGUAY,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_BOLIVIA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_EL_SALVADOR,	"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_HONDURAS,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_NICARAGUA,		"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_PUERTO_RICO,	"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FINNISH_FINLAND,		"fi" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_FRANCE,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_BELGIUM,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_CANADA,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_SWITZERLAND,	"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_LUXEMBOURG,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_MONACO,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_HEBREW_ISRAEL,		"he" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_HUNGARIAN_HUNGARY,		"hu" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ICELANDIC_ICELAND,		"is" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ITALIAN_ITALY,		"it" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ITALIAN_SWITZERLAND,	"it" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_JAPANESE_JAPAN,		"ja" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KOREAN_EXTENDED_WANSUNG_KOREA,"ko" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KOREAN_JOHAB_KOREA,	"ko" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_DUTCH_NETHERLANDS,		"nl" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_DUTCH_BELGIUM,		"nl" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_NORWEGIAN_NORWAY_BOKMAL,	"no" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_NORWEGIAN_NORWAY_NYNORSK,	"nn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_POLISH_POLAND,		"pl" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_PORTUGUESE_BRAZIL,		"pt" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_PORTUGUESE_PORTUGAL,	"pt" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_RHAETO_ROMANIC_SWITZERLAND,"rm" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ROMANIAN_ROMANIA,		"ro" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MOLDAVIAN_MOLDAVIA,	"mo" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_RUSSIAN_RUSSIA,		"ru" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_RUSSIAN_MOLDAVIA,		"ru" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CROATIAN_CROATIA,		"hr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SERBIAN_SERBIA_LATIN,	"sr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SERBIAN_SERBIA_CYRILLIC,	"sr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SLOVAK_SLOVAKIA,		"sk" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ALBANIAN_ALBANIA,		"sq" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SWEDISH_SWEDEN,		"sv" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SWEDISH_FINLAND,		"sv" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_THAI_THAILAND,		"th" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TURKISH_TURKEY,		"tr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_URDU_PAKISTAN,		"ur" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_INDONESIAN_INDONESIA,	"id" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_UKRAINIAN_UKRAINE,		"uk" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BELARUSIAN_BELARUS,	"be" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SLOVENE_SLOVENIA,		"sl" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ESTONIAN_ESTONIA,		"et" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_LATVIAN_LATVIA,		"lv" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_LITHUANIAN_LITHUANIA,	"lt" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CLASSIC_LITHUANIAN_LITHUANIA,"lt" },
    
#ifdef TT_MS_LANGID_MAORI_NEW_ZELAND
    /* this seems to be an error that have been dropped */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MAORI_NEW_ZEALAND,		"mi" },
#endif
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FARSI_IRAN,		"fa" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_VIETNAMESE_VIET_NAM,	"vi" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARMENIAN_ARMENIA,		"hy" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_AZERI_AZERBAIJAN_LATIN,	"az" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_AZERI_AZERBAIJAN_CYRILLIC,	"az" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BASQUE_SPAIN,		"eu" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SORBIAN_GERMANY,		"wen" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MACEDONIAN_MACEDONIA,	"mk" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SUTU_SOUTH_AFRICA,		"st" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TSONGA_SOUTH_AFRICA,	"ts" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TSWANA_SOUTH_AFRICA,	"tn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_VENDA_SOUTH_AFRICA,	"ven" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_XHOSA_SOUTH_AFRICA,	"xh" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ZULU_SOUTH_AFRICA,		"zu" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_AFRIKAANS_SOUTH_AFRICA,	"af" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GEORGIAN_GEORGIA,		"ka" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FAEROESE_FAEROE_ISLANDS,	"fo" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_HINDI_INDIA,		"hi" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MALTESE_MALTA,		"mt" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SAAMI_LAPONIA,		"se" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SCOTTISH_GAELIC_UNITED_KINGDOM,"gd" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_IRISH_GAELIC_IRELAND,	"ga" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MALAY_MALAYSIA,		"ms" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MALAY_BRUNEI_DARUSSALAM,	"ms" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KAZAK_KAZAKSTAN,		"kk" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SWAHILI_KENYA,		"sw" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_UZBEK_UZBEKISTAN_LATIN,	"uz" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_UZBEK_UZBEKISTAN_CYRILLIC,	"uz" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TATAR_TATARSTAN,		"tt" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BENGALI_INDIA,		"bn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_PUNJABI_INDIA,		"pa" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GUJARATI_INDIA,		"gu" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ORIYA_INDIA,		"or" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TAMIL_INDIA,		"ta" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TELUGU_INDIA,		"te" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KANNADA_INDIA,		"kn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MALAYALAM_INDIA,		"ml" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ASSAMESE_INDIA,		"as" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MARATHI_INDIA,		"mr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SANSKRIT_INDIA,		"sa" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KONKANI_INDIA,		"kok" },
    
    /* new as of 2001-01-01 */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ARABIC_GENERAL,		"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHINESE_GENERAL,		"zh" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_GENERAL,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_WEST_INDIES,	"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_REUNION,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_CONGO,		"fr" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_SENEGAL,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_CAMEROON,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_COTE_D_IVOIRE,	"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_MALI,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BOSNIAN_BOSNIA_HERZEGOVINA,"bs" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_URDU_INDIA,		"ur" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TAJIK_TAJIKISTAN,		"tg" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_YIDDISH_GERMANY,		"yi" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KIRGHIZ_KIRGHIZSTAN,	"ky" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TURKMEN_TURKMENISTAN,	"tk" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MONGOLIAN_MONGOLIA,	"mn" },
    
    /* the following seems to be inconsistent;
     here is the current "official" way: */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TIBETAN_BHUTAN,		"bo" },
    /* and here is what is used by Passport SDK */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TIBETAN_CHINA,		"bo" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_DZONGHKA_BHUTAN,		"dz" },
    /* end of inconsistency */
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_WELSH_WALES,		"cy" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KHMER_CAMBODIA,		"km" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_LAO_LAOS,			"lo" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BURMESE_MYANMAR,		"my" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GALICIAN_SPAIN,		"gl" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MANIPURI_INDIA,		"mni" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SINDHI_INDIA,		"sd" },
    /* the following one is only encountered in Microsoft RTF specification */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KASHMIRI_PAKISTAN,		"ks" },
    /* the following one is not in the Passport list, looks like an omission */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KASHMIRI_INDIA,		"ks" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_NEPALI_NEPAL,		"ne" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_NEPALI_INDIA,		"ne" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRISIAN_NETHERLANDS,	"fy" },
    
    /* new as of 2001-03-01 (from Office Xp) */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_HONG_KONG,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_INDIA,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_MALAYSIA,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_ENGLISH_SINGAPORE,		"en" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SYRIAC_SYRIA,		"syr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SINHALESE_SRI_LANKA,	"si" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_CHEROKEE_UNITED_STATES,	"chr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_INUKTITUT_CANADA,		"iu" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_AMHARIC_ETHIOPIA,		"am" },
#if 0
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TAMAZIGHT_MOROCCO },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TAMAZIGHT_MOROCCO_LATIN },
#endif
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_PASHTO_AFGHANISTAN,	"ps" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FILIPINO_PHILIPPINES,	"phi" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_DHIVEHI_MALDIVES,		"div" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_OROMO_ETHIOPIA,		"om" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TIGRIGNA_ETHIOPIA,		"ti" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_TIGRIGNA_ERYTHREA,		"ti" },
    
    /* New additions from Windows Xp/Passport SDK 2001-11-10. */
    
    /* don't ask what this one means... It is commented out currently. */
#if 0
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GREEK_GREECE2 },
#endif
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_UNITED_STATES,	"es" },
    /* The following two IDs blatantly violate MS specs by using a */
    /* sublanguage >,.                                         */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SPANISH_LATIN_AMERICA,	"es" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_NORTH_AFRICA,	"fr" },
    
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_MOROCCO,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FRENCH_HAITI,		"fr" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_BENGALI_BANGLADESH,	"bn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_PUNJABI_ARABIC_PAKISTAN,	"ar" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_MONGOLIAN_MONGOLIA_MONGOLIAN,"mn" },
#if 0
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_EDO_NIGERIA },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_FULFULDE_NIGERIA },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_IBIBIO_NIGERIA },
#endif
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_HAUSA_NIGERIA,		"ha" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_YORUBA_NIGERIA,		"yo" },
    /* language codes from, to, are (still) unknown. */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_IGBO_NIGERIA,		"ibo" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_KANURI_NIGERIA,		"kau" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_GUARANI_PARAGUAY,		"gn" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_HAWAIIAN_UNITED_STATES,	"haw" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_LATIN,			"la" },
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_SOMALI_SOMALIA,		"so" },
#if 0
    /* Note: Yi does not have a (proper) ISO 639-2 code, since it is mostly */
    /*       not written (but OTOH the peculiar writing system is worth     */
    /*       studying).                                                     */
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_YI_CHINA },
#endif
    {  TT_PLATFORM_MICROSOFT,	TT_MS_LANGID_PAPIAMENTU_NETHERLANDS_ANTILLES,"pap" },
};

#define NUM_FT_LANGUAGES  (int) (sizeof (ftLanguages) / sizeof (ftLanguages[0]))

NSDate *   FTDateTime(NSInteger value) {
    NSDate * epoch = [NSDate dateWithString:@"1904-01-01 00:00:00 +0000"];
    return [[NSDate alloc] initWithTimeInterval:value sinceDate:epoch];
}

NSString * FTDateTimeToString(NSInteger value) {
    return [FTDateTime(value) description];
}

static NSString * FTGetUnicodeStringMacintosh(FT_UShort encodingId, void * string, uint32_t stringLen) {
    if (encodingId == TT_MAC_ID_ROMAN)
        return [[NSString alloc] initWithBytes:string length:stringLen encoding:NSMacOSRomanStringEncoding];
    
    NSString * name = nil;
    
    while (true) {
        OSStatus error = 0;
        TextEncoding textEncoding;
        error = UpgradeScriptInfoToTextEncoding(encodingId,
                                                kTextLanguageDontCare,
                                                kTextRegionDontCare,
                                                NULL,
                                                &textEncoding);
        if (error) break;
        
        TextToUnicodeInfo textToUnicodeInfo;
        error = CreateTextToUnicodeInfoByEncoding(textEncoding, &textToUnicodeInfo);
        if (error) break;
        
        ByteCount sourceRead = 0, unicodeLen = 0;
        
        int bufLen = stringLen * 4;
        UniChar * buf = (UniChar*)malloc(bufLen * sizeof(UniChar));
        error = ConvertFromTextToUnicode(textToUnicodeInfo,
                                         stringLen, string,
                                         0, 0, 0, 0, 0, // no font offset
                                         bufLen, &sourceRead, &unicodeLen,
                                         buf);
        
        if (!error)
            name = [[NSString alloc] initWithCharacters:buf length:unicodeLen/2];
        
        DisposeTextToUnicodeInfo(&textToUnicodeInfo);
        free(buf);
        break;
    }
    
    return name;
}

static NSString * FTGetUnicodeStringAppleUnicode(FT_UShort encodingId, void * string, uint32_t stringLen) {
    return [[NSString alloc] initWithBytes:string length:stringLen encoding:NSUnicodeStringEncoding];
}

static NSString * FTGetUnicodeStringMicrosoft(FT_UShort encodingId, void * string, uint32_t stringLen) {
    NSStringEncoding enc = kCFStringEncodingInvalidId;
    
    BOOL mbs = NO;
    switch(encodingId) {
        case TT_MS_ID_UNICODE_CS: // UTF16-BE
        case TT_MS_ID_SYMBOL_CS:
            enc = NSUTF16BigEndianStringEncoding;
            break;
        case TT_MS_ID_UCS_4:
            enc = NSUTF32BigEndianStringEncoding;
            break;
        case TT_MS_ID_PRC:
            enc = (NSStringEncoding)CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            mbs = YES;
            break;
        case TT_MS_ID_SJIS:
            enc = NSShiftJISStringEncoding;
            mbs = YES;
            break;
        case TT_MS_ID_BIG_5:
            enc = (NSStringEncoding)CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            mbs = YES;
            break;
        default:
            break;
    }
    
    if (enc == kCFStringEncodingInvalidId)
        return nil;
    
    if (mbs) {
        // byte 0 is not valid in MBS, so remove all byte 0
        unsigned char * trimed = (unsigned char *) malloc(stringLen);
        uint32_t trimedLen = 0;
        for (uint32_t i = 0; i < stringLen; ++ i) {
            unsigned char c = ((unsigned char *)string)[i];
            if (c) trimed[trimedLen++] = c;
        }
        if (trimedLen)
            return [[NSString alloc] initWithBytes:trimed length:trimedLen encoding:enc];
        else
            return nil;
    }
    return [[NSString alloc] initWithBytes:string length:stringLen encoding:enc];
}

NSString * FTGetUnicodeString(FT_UShort platformId, FT_UShort encodingId, void * string, uint32_t stringLen) {
    NSString * str = nil;
    switch(platformId) {
        case TT_PLATFORM_MACINTOSH: str = FTGetUnicodeStringMacintosh(encodingId, string, stringLen); break;
        case TT_PLATFORM_MICROSOFT: str = FTGetUnicodeStringMicrosoft(encodingId, string, stringLen); break;
        case TT_PLATFORM_APPLE_UNICODE: str = FTGetUnicodeStringAppleUnicode(encodingId, string, stringLen); break;
        default: break;
    }
    
    if (!str)
        str = [[NSString alloc] initWithBytes:string length:stringLen encoding:NSISOLatin1StringEncoding]; // IEC_8859-1
    return str;
}


NSString * FTGetPlatformName(FT_UShort platformId) {
    switch (platformId) {
        case TT_PLATFORM_APPLE_UNICODE: return  @"Unicode";
        case TT_PLATFORM_MACINTOSH: return @"(deprecated) Macintosh";
        case TT_PLATFORM_ISO: return @"ISO";
        case TT_PLATFORM_MICROSOFT: return @"Microsoft";
        case TT_PLATFORM_ADOBE: return @"Adobe";
        default: return @"Unknown Platform";
    }
}

NSString * FTGetPlatformEncodingName(FT_UShort platformId, FT_UShort encodingId) {
    NSDictionary<NSNumber*, NSString*> * encodings;
    
    switch (platformId) {
        case TT_PLATFORM_APPLE_UNICODE:
            encodings =  @{
                           @TT_APPLE_ID_DEFAULT:                  @"1.0",
                            @TT_APPLE_ID_UNICODE_1_1:              @"1.1",
                            @TT_APPLE_ID_ISO_10646:                @"ISO/IEC 10646",
                            @TT_APPLE_ID_UNICODE_2_0:              @"2.0, BMP only",
                            @TT_APPLE_ID_UNICODE_32:               @"2.0, full repertoire",
                            @TT_APPLE_ID_VARIANT_SELECTOR:         @"Variation Sequences",
                            @6:                                    @"full repertoire",
                            };
            break;
        case TT_PLATFORM_MACINTOSH:
            encodings = @{
                          @TT_MAC_ID_ROMAN:                       @"Roman",
                           @TT_MAC_ID_JAPANESE:                    @"Japanese",
                           @TT_MAC_ID_TRADITIONAL_CHINESE:         @"Chinese (Traditional)",
                           @TT_MAC_ID_KOREAN:                      @"Korean",
                           @TT_MAC_ID_ARABIC:                      @"Arabic",
                           @TT_MAC_ID_HEBREW:                      @"Hebrew",
                           @TT_MAC_ID_GREEK:                       @"Greek",
                           @TT_MAC_ID_RUSSIAN:                     @"Russian",
                           @TT_MAC_ID_RSYMBOL:                     @"RSymbol",
                           @TT_MAC_ID_DEVANAGARI:                  @"Devanagari",
                           @TT_MAC_ID_GURMUKHI:                    @"Gurmukhi",
                           @TT_MAC_ID_GUJARATI:                    @"Gujarati",
                           @TT_MAC_ID_ORIYA:                       @"Oriya",
                           @TT_MAC_ID_BENGALI:                     @"Bengali",
                           @TT_MAC_ID_TAMIL:                       @"Tamil",
                           @TT_MAC_ID_TELUGU:                      @"Telugu",
                           @TT_MAC_ID_KANNADA:                     @"Kannada",
                           @TT_MAC_ID_MALAYALAM:                   @"Malayalam",
                           @TT_MAC_ID_SINHALESE:                   @"Sinhalese",
                           @TT_MAC_ID_BURMESE:                     @"Burmese",
                           @TT_MAC_ID_KHMER:                       @"Khmer",
                           @TT_MAC_ID_THAI:                        @"Thai",
                           @TT_MAC_ID_LAOTIAN:                     @"Laotian",
                           @TT_MAC_ID_GEORGIAN:                    @"Georgian",
                           @TT_MAC_ID_ARMENIAN:                    @"Armenian",
                           @TT_MAC_ID_SIMPLIFIED_CHINESE:          @"Chinese (Simplified)",
                           @TT_MAC_ID_TIBETAN:                     @"Tibetan",
                           @TT_MAC_ID_MONGOLIAN:                   @"Mongolian",
                           @TT_MAC_ID_GEEZ:                        @"Geez",
                           @TT_MAC_ID_SLAVIC:                      @"Slavic",
                           @TT_MAC_ID_VIETNAMESE:                  @"Vietnamese",
                           @TT_MAC_ID_SINDHI:                      @"Sindhi",
                           @TT_MAC_ID_UNINTERP:                    @"Uninterpreted",
                           };
            break;
            
        case TT_PLATFORM_ISO:
            encodings = @{
                          @TT_ISO_ID_7BIT_ASCII:                  @"7-bit ASCII",
                           @TT_ISO_ID_10646:                       @"10646",
                           @TT_ISO_ID_8859_1:                      @"8859-1",
                           };
            break;
            
        case TT_PLATFORM_MICROSOFT:
            encodings = @{
                          @TT_MS_ID_SYMBOL_CS:                    @"Symbol",
                           @TT_MS_ID_UNICODE_CS:                   @"Unicode BMP",
                           @TT_MS_ID_SJIS:                         @"ShiftJIS",
                           @TT_MS_ID_GB2312:                       @"RPC",
                           @TT_MS_ID_WANSUNG:                      @"Big5",
                           @TT_MS_ID_WANSUNG:                      @"Wansung",
                           @TT_MS_ID_JOHAB:                        @"Johab",
                           @7:                                     @"Reserved",
                           @8:                                     @"Reserved",
                           @9:                                     @"Reserved",
                           @TT_MS_ID_UCS_4:                        @"Unicode UCS-4",
                           };
            break;
        case TT_PLATFORM_ADOBE:
            encodings = @{
                          @TT_ADOBE_ID_STANDARD:                  @"Standard",
                           @TT_ADOBE_ID_EXPERT:                    @"Expert",
                           @TT_ADOBE_ID_CUSTOM:                    @"Custom",
                           @TT_ADOBE_ID_LATIN_1:                   @"Latin 1",
                           };
            break;
            
        default:
            break;
            
    }
    
    NSString * encodingName = [encodings objectForKey:[NSNumber numberWithUnsignedInteger:encodingId]];
    if (!encodingName)
        encodingName = @"Unknown Encoding";
    
    return [NSString stringWithFormat:@"%@ %@ (%lu-%lu)", FTGetPlatformName(platformId), encodingName, (unsigned long)platformId, (unsigned long)encodingId];
}


NSString * FTGetPlatformLanguageName(FT_UShort platformId, FT_UShort languageId) {
    for (int i = 0; i < NUM_FT_LANGUAGES; i++)
        if (ftLanguages[i].platform_id == platformId &&
            (ftLanguages[i].language_id == TT_LANGUAGE_DONT_CARE ||
             ftLanguages[i].language_id == languageId))
        {
            if (ftLanguages[i].lang[0] == '\0')
                return NULL;
            else
                return [NSString stringWithUTF8String:ftLanguages[i].lang];
        }
    return nil;
}

NSString * SFNTNameGetName(FT_SfntName * sfntName) {
    const char * names[] = {
        "Copyright",
        "Font Family",
        "Font Subfamily",
        "Unique ID",
        "Full Name",
        "Version",
        "PS Name",
        "Trademark",
        "Manufacturer",
        "Designer",
        "Description",
        "Vendor URL",
        "Designer URL",
        "License",
        "License URL",
        "15",
        "Typographic Family",
        "Typographic Subfamily",
        "Mac Fullname",
        "Sample Text",
        "CID Findfont Name",
        "WWS Family",
        "WWS Subfamily",
        "Light Background",
        "Dark Background",
        "Variations Prefix",
    };
    
    if (sfntName->name_id >= sizeof(names)/sizeof(names[0]))
        return [NSString stringWithFormat:@"%d", sfntName->name_id];
    return [NSString stringWithUTF8String:names[sfntName->name_id]];
}

NSString * SFNTNameGetValue(FT_SfntName * sfntName) {
    return FTGetUnicodeString(sfntName->platform_id, sfntName->encoding_id, sfntName->string, sfntName->string_len);
}

NSString * SFNTNameGetLanguage(FT_SfntName *sfntName, FT_Face face) {
    if (sfntName->language_id >= 0x8000) {
        FT_SfntLangTag langTag;
        if (!FT_Get_Sfnt_LangTag(face, sfntName->language_id, &langTag)) {
            return FTGetUnicodeString(sfntName->platform_id, sfntName->encoding_id, langTag.string, langTag.string_len);
        }
    }
    return FTGetPlatformLanguageName(sfntName->platform_id, sfntName->language_id);
}


BOOL SFNTNameGetFromId(FT_Face face, NSUInteger nameId, FT_SfntName * sfnt) {
    FT_UInt count = FT_Get_Sfnt_Name_Count(face);

    for (FT_UInt i = 0; i < count; ++ i) {
        FT_SfntName sfntName;
        if (!FT_Get_Sfnt_Name(face, i, &sfntName) && (sfntName.name_id == nameId)) {
            *sfnt = sfntName;
            return YES;
        }
    }
    return NO;
}

NSString * SFNTNameGetValueFromId(FT_Face face, NSUInteger nameId) {
    FT_SfntName name;
    if (SFNTNameGetFromId(face, nameId, &name))
        return SFNTNameGetValue(&name);
    return nil;
}

NSString * SFNTTagName(FT_ULong tagValue) {
    char buf [] = {tagValue >> 24, tagValue >> 16, tagValue >> 8, tagValue};
    return [[NSString alloc] initWithBytes:buf length:4 encoding:NSASCIIStringEncoding];
}


NSString * HeadGetFlagFullDescription(uint16_t flag) {
   
    NSMutableString * description = [[NSMutableString alloc] init];
    [description appendFormat:@"Baseline at Y = 0: %@;", (flag & (1 << 0))? @"YES": @"NO"];
    [description appendFormat:@"Left sidebearing at X = 0: %@;", (flag & (1 << 1))? @"YES": @"NO"];
    [description appendFormat:@"Instructions depends on point size: %@;", (flag & (1 << 2))? @"YES": @"NO"];
    [description appendFormat:@"Force ppem to integer values: %@;" , (flag & (1 << 3))? @"YES": @"NO"];
    [description appendFormat:@"Instructions may alter advance width: %@;", (flag & (1 << 4))? @"YES": @"NO"];
    [description appendFormat:@"Font data is ‘lossless’ compressed: %@;", (flag & (1 << 11))? @"YES": @"NO"];
    [description appendFormat:@"Font converted: %@;", (flag & (1 << 12))? @"YES": @"NO"];
    [description appendFormat:@"Font optimized for ClearType™: %@;", (flag & (1 << 13))? @"YES": @"NO"];
    [description appendFormat:@"Last Resort font: %@;", (flag & (1 << 14))? @"YES": @"NO"];

    return description;
}

NSString * OS2GetWeightClassName(uint16_t value) {
    switch (value) {
        case 100: return @"Thin";
        case 200: return @"Extra-light (Ultra-light)";
        case 300: return @"Light";
        case 400: return @"Normal (Regular)";
        case 500: return @"Medium";
        case 600: return @"Semi-bold (Demi-bold)";
        case 700: return @"Bold";
        case 800: return @"Extra-bold (Ultra-bold)";
        case 900: return @"Black (Heavy)";
        default: return @"Unknown";
    }
}

NSString * OS2GetWidthClassName(uint16_t value) {
    switch (value) {
        case 1: return @"Ultra-condensed";
        case 2: return @"Extra-condensed";
        case 3: return @"Condensed";
        case 4: return @"Semi-condensed";
        case 5: return @"Medium (normal)";
        case 6: return @"Semi-expanded";
        case 7: return @"Expanded";
        case 8: return @"Extra-expanded";
        case 9: return @"Ultra-expanded";
        default: return @"Unknown";
    }
}


NSString * OS2GetFamilyClassName(uint16_t value) {
    NSUInteger family = ((value & 0xFF00) >> 8);
    
    NSArray<NSString *> * names = @[@"No classification",
                                    @"OldStyle Serifs",
                                    @"Transitional Serifs",
                                    @"Modern Serifs",
                                    @"Clarendon Serifs",
                                    @"Slab Serifs",
                                    @"Reserved",
                                    @"Freeform Serifs",
                                    @"Sans Serif",
                                    @"Ornamentals",
                                    @"Scripts",
                                    @"reserved",
                                    @"Symbolic",
                                    @"reserved",
                                    @"reserved",
                                    ];
    if (family < names.count)
        return [names objectAtIndex:family];
    return @"Unknown Family Class";
}

NSString * OS2GetSubFamilyClassName(uint16_t value) {
    NSUInteger family = ((value & 0xFF00) >> 8);
    NSUInteger subFamily = (value & 0xFF);

    NSArray<NSString*> * subFamilyNames = nil;
    switch (family) {
        case 1: subFamilyNames = @[@"No classification",
                                   @"IBM Rounded Legibility",
                                   @"Garalde",
                                   @"Venetian",
                                   @"Modified Venetian",
                                   @"Dutch Modern",
                                   @"Dutch Traditional",
                                   @"Contemporary",
                                   @"Calligraphic",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"Miscellaneous"];
            break;
        case 2: subFamilyNames = @[@"No Classification",
                                   @"Direct Line",
                                   @"Script",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"Miscellaneous"];
            break;
        case 3: subFamilyNames = @[@"No Classification",
                                   @"Italian",
                                   @"Script",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"Miscellaneous"];
            break;
        case 4: subFamilyNames = @[@"No Classification",
                                   @"Clarendon",
                                   @"Modern",
                                   @"Traditional",
                                   @"Newspaper",
                                   @"Stub Serif",
                                   @"Monotone",
                                   @"Typewriter",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"Miscellaneous"];
            break;
        case 5: subFamilyNames = @[@"No classification",
                                   @"Monotone",
                                   @"Humanist",
                                   @"Geometric",
                                   @"Swiss",
                                   @"Typewriter",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"Miscellaneous"];
            break;
        case 7: subFamilyNames = @[@"No classification",
                                   @"Modern",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"reserved",
                                   @"Miscellaneous"];
            break;
        case 8: subFamilyNames = @[@"No classification",
                                   @"IBM Neo-grotesque Gothic",
                                   @"Humanist",
                                   @"Low-x Round Geometric",
                                   @"High-x Round Geometric",
                                   @"Neo-grotesque Gothic",
                                   @"Modified neo-grotesque Gothic",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Typewriter Gothic",
                                   @"Matrix",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Miscellaneous"];
            break;
        case 9: subFamilyNames = @[@"No classification",
                                   @"Engraver",
                                   @"Black Letter",
                                   @"Decorative",
                                   @"Three Dimensional",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Reserved",
                                   @"Miscellaneous",];
            break;
        case 10: subFamilyNames = @[@"No classification",
                                    @"Uncial",
                                    @"Brush Joined",
                                    @"Formal Joined",
                                    @"Monotone Joined",
                                    @"Calligraphic",
                                    @"Brush Unjoined",
                                    @"Formal Unjoined",
                                    @"Monotone Unjoined",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Miscellaneous",];
            break;
        case 12: subFamilyNames = @[@"No classification",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Mixed Serif",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Oldstyle Serif",
                                    @"Neo-grotesque Sans Serif",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Reserved",
                                    @"Miscellaneous",];
            break;
            
        default:
            break;
    }
    
    if (subFamily < subFamilyNames.count)
        return [subFamilyNames objectAtIndex:subFamily];
    
    return @"Unknown SubFamily Class";
}

NSString * OS2GetFamilyClassFullName(uint16_t value) {
    return [NSString stringWithFormat:@"%@, %@", OS2GetFamilyClassName(value), OS2GetSubFamilyClassName(value)];
}

NSString * OS2GetFsSelectionNames(uint16_t value) {
    NSMutableArray<NSString*> * names = [[NSMutableArray<NSString*> alloc] init];
    
    if (value & (1 << 0)) [names addObject:@"Italic"];
    if (value & (1 << 1)) [names addObject:@"Underscore"];
    if (value & (1 << 2)) [names addObject:@"Negative"];
    if (value & (1 << 3)) [names addObject:@"Outlined"];
    if (value & (1 << 4)) [names addObject:@"Strikeout"];
    if (value & (1 << 5)) [names addObject:@"Bold"];
    if (value & (1 << 6)) [names addObject:@"Regular"];
    if (value & (1 << 7)) [names addObject:@"Use Typo Metrics"];
    if (value & (1 << 8)) [names addObject:@"WWS"];
    if (value & (1 << 9)) [names addObject:@"Oblique"];

    
    return [names componentsJoinedByString:@", "];
}


NSString * OTGetScriptFullName(NSString * script) {
    NSDictionary<NSString*, NSString *> * scriptFullNameMapping =
    @{
      @"Arabic": @"arab",
      @"Armenian": @"armn",
      @"Avestan": @"avst",
      @"Balinese": @"bali",
      @"Bamum": @"bamu",
      @"Batak": @"batk",
      @"Bengali": @"beng",
      @"Bengali v.2": @"bng2",
      @"Bopomofo": @"bopo",
      @"Braille": @"brai",
      @"Brahmi": @"brah",
      @"Buginese": @"bugi",
      @"Buhid": @"buhd",
      @"Byzantine Music": @"byzm",
      @"Canadian Syllabics": @"cans",
      @"Carian": @"cari",
      @"Chakma": @"cakm",
      @"Cham": @"cham",
      @"Cherokee": @"cher",
      @"CJK Ideographic": @"hani",
      @"Coptic": @"copt",
      @"Cypriot Syllabary": @"cprt",
      @"Cyrillic": @"cyrl",
      @"Default": @"DFLT",
      @"Deseret": @"dsrt",
      @"Devanagari": @"deva",
      @"Devanagari v.2": @"dev2",
      @"Egyptian heiroglyphs": @"egyp",
      @"Ethiopic": @"ethi",
      @"Georgian": @"geor",
      @"Glagolitic": @"glag",
      @"Gothic": @"goth",
      @"Greek": @"grek",
      @"Gujarati": @"gujr",
      @"Gujarati v.2": @"gjr2",
      @"Gurmukhi": @"guru",
      @"Gurmukhi v.2": @"gur2",
      @"Hangul": @"hang",
      @"Hangul Jamo": @"jamo",
      @"Hanunoo": @"hano",
      @"Hebrew": @"hebr",
      @"Hiragana": @"kana",
      @"Imperial Aramaic": @"armi",
      @"Inscriptional Pahlavi": @"phli",
      @"Inscriptional Parthian": @"prti",
      @"Javanese": @"java",
      @"Kaithi": @"kthi",
      @"Kannada": @"knda",
      @"Kannada v.2": @"knd2",
      @"Katakana": @"kana",
      @"Kayah Li": @"kali",
      @"Kharosthi": @"khar",
      @"Khmer": @"khmr",
      @"Lao": @"lao",
      @"Latin": @"latn",
      @"Lepcha": @"lepc",
      @"Limbu": @"limb",
      @"Linear B": @"linb",
      @"Lisu (Fraser)": @"lisu",
      @"Lycian": @"lyci",
      @"Lydian": @"lydi",
      @"Malayalam": @"mlym",
      @"Malayalam v.2": @"mlm2",
      @"Mandaic, Mandaean": @"mand",
      @"Mathematical Alphanumeric Symbols": @"math",
      @"Meitei Mayek (Meithei, Meetei)": @"mtei",
      @"Meroitic Cursive": @"merc",
      @"Meroitic Hieroglyphs": @"mero",
      @"Mongolian": @"mong",
      @"Musical Symbols": @"musc",
      @"Myanmar": @"mymr",
      @"New Tai Lue": @"talu",
      @"N'Ko": @"nko",
      @"Ogham": @"ogam",
      @"Ol Chiki": @"olck",
      @"Old Italic": @"ital",
      @"Old Persian Cuneiform": @"xpeo",
      @"Old South Arabian": @"sarb",
      @"Old Turkic, Orkhon Runic": @"orkh",
      @"Odia (formerly Oriya)": @"orya",
      @"Odia v.2 (formerly Oriya v.2)": @"ory2",
      @"Osmanya": @"osma",
      @"Phags-pa": @"phag",
      @"Phoenician": @"phnx",
      @"Rejang": @"rjng",
      @"Runic": @"runr",
      @"Samaritan": @"samr",
      @"Saurashtra": @"saur",
      @"Sharada": @"shrd",
      @"Shavian": @"shaw",
      @"Sinhala": @"sinh",
      @"Sora Sompeng": @"sora",
      @"Sumero-Akkadian Cuneiform": @"xsux",
      @"Sundanese": @"sund",
      @"Syloti Nagri": @"sylo",
      @"Syriac": @"syrc",
      @"Tagalog": @"tglg",
      @"Tagbanwa": @"tagb",
      @"Tai Le": @"tale",
      @"Tai Tham (Lanna)": @"lana",
      @"Tai Viet": @"tavt",
      @"Takri": @"takr",
      @"Tamil": @"taml",
      @"Tamil v.2": @"tml2",
      @"Telugu": @"telu",
      @"Telugu v.2": @"tel2",
      @"Thaana": @"thaa",
      @"Thai": @"thai",
      @"Tibetan": @"tibt",
      @"Tifinagh": @"tfng",
      @"Ugaritic Cuneiform": @"ugar",
      @"Vai": @"vai",
      @"Yi": @"yi",
      };

    NSString * scriptTrimed = [script stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * key in scriptFullNameMapping) {
        NSString * value = [scriptFullNameMapping objectForKey:key];
        if ([value compare:scriptTrimed options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return key;
    }
    return script;
}

NSString * OTGetLanguageFullName(NSString * language) {
    NSDictionary<NSString*, NSString *> * languageFullNameMapping =
    @{
      @"Abaza": @"ABA",
      @"Abkhazian": @"ABK",
      @"Adyghe": @"ADY",
      @"Afrikaans": @"AFK",
      @"Afar": @"AFR",
      @"Agaw": @"AGW",
      @"Alsatian": @"ALS",
      @"Altai": @"ALT",
      @"Amharic": @"AMH",
      @"Phonetic transcription—Americanist conventions": @"APPH",
      @"Arabic": @"ARA",
      @"Aari": @"ARI",
      @"Arakanese": @"ARK",
      @"Assamese": @"ASM",
      @"Athapaskan": @"ATH",
      @"Avar": @"AVR",
      @"Awadhi": @"AWA",
      @"Aymara": @"AYM",
      @"Azeri": @"AZE",
      @"Badaga": @"BAD",
      @"Baghelkhandi": @"BAG",
      @"Balkar": @"BAL",
      @"Baule": @"BAU",
      @"Berber": @"BBR",
      @"Bench": @"BCH",
      @"Bible Cree": @"BCR",
      @"Belarussian": @"BEL",
      @"Bemba": @"BEM",
      @"Bengali": @"BEN",
      @"Bulgarian": @"BGR",
      @"Bhili": @"BHI",
      @"Bhojpuri": @"BHO",
      @"Bikol": @"BIK",
      @"Bilen": @"BIL",
      @"Blackfoot": @"BKF",
      @"Balochi": @"BLI",
      @"Balante": @"BLN",
      @"Balti": @"BLT",
      @"Bambara": @"BMB",
      @"Bamileke": @"BML",
      @"Bosnian": @"BOS",
      @"Breton": @"BRE",
      @"Brahui": @"BRH",
      @"Braj Bhasha": @"BRI",
      @"Burmese": @"BRM",
      @"Bashkir": @"BSH",
      @"Beti": @"BTI",
      @"Catalan": @"CAT",
      @"Cebuano": @"CEB",
      @"Chechen": @"CHE",
      @"Chaha Gurage": @"CHG",
      @"Chattisgarhi": @"CHH",
      @"Chichewa": @"CHI",
      @"Chukchi": @"CHK",
      @"Chipewyan": @"CHP",
      @"Cherokee": @"CHR",
      @"Chuvash": @"CHU",
      @"Comorian": @"CMR",
      @"Coptic": @"COP",
      @"Corsican": @"COS",
      @"Cree": @"CRE",
      @"Carrier": @"CRR",
      @"Crimean Tatar": @"CRT",
      @"Church Slavonic": @"CSL",
      @"Czech": @"CSY",
      @"Danish": @"DAN",
      @"Dargwa": @"DAR",
      @"Woods Cree": @"DCR",
      @"German": @"DEU",
      @"Default": @"dlft",
      @"Dogri": @"DGR",
      @"Dhivehi": @"DHV (deprecated)",
      @"Dhivehi": @"DIV",
      @"Djerma": @"DJR",
      @"Dangme": @"DNG",
      @"Dinka": @"DNK",
      @"Dari": @"DRI",
      @"Dungan": @"DUN",
      @"Dzongkha": @"DZN",
      @"Ebira": @"EBI",
      @"Eastern Cree": @"ECR",
      @"Edo": @"EDO",
      @"Efik": @"EFI",
      @"Greek": @"ELL",
      @"English": @"ENG",
      @"Erzya": @"ERZ",
      @"Spanish": @"ESP",
      @"Estonian": @"ETI",
      @"Basque": @"EUQ",
      @"Evenki": @"EVK",
      @"Even": @"EVN",
      @"Ewe": @"EWE",
      @"French Antillean": @"FAN",
      @"Farsi": @"FAR",
      @"Finnish": @"FIN",
      @"Fijian": @"FJI",
      @"Flemish": @"FLE",
      @"Forest Nenets": @"FNE",
      @"Fon": @"FON",
      @"Faroese": @"FOS",
      @"French": @"FRA",
      @"Frisian": @"FRI",
      @"Friulian": @"FRL",
      @"Futa": @"FTA",
      @"Fulani": @"FUL",
      @"Ga": @"GAD",
      @"Gaelic": @"GAE",
      @"Gagauz": @"GAG",
      @"Galician": @"GAL",
      @"Garshuni": @"GAR",
      @"Garhwali": @"GAW",
      @"Ge'ez": @"GEZ",
      @"Gilyak": @"GIL",
      @"Gumuz": @"GMZ",
      @"Gondi": @"GON",
      @"Greenlandic": @"GRN",
      @"Garo": @"GRO",
      @"Guarani": @"GUA",
      @"Gujarati": @"GUJ",
      @"Haitian": @"HAI",
      @"Halam": @"HAL",
      @"Harauti": @"HAR",
      @"Hausa": @"HAU",
      @"Hawaiin": @"HAW",
      @"Hammer-Banna": @"HBN",
      @"Hiligaynon": @"HIL",
      @"Hindi": @"HIN",
      @"High Mari": @"HMA",
      @"Hindko": @"HND",
      @"Ho": @"HO",
      @"Harari": @"HRI",
      @"Croatian": @"HRV",
      @"Hungarian": @"HUN",
      @"Armenian": @"HYE",
      @"Igbo": @"IBO",
      @"Ijo": @"IJO",
      @"Ilokano": @"ILO",
      @"Indonesian": @"IND",
      @"Ingush": @"ING",
      @"Inuktitut": @"INU",
      @"Phonetic transcription—IPA conventions": @"IPPH",
      @"Irish": @"IRI",
      @"Irish Traditional": @"IRT",
      @"Icelandic": @"ISL",
      @"Inari Sami": @"ISM",
      @"Italian": @"ITA",
      @"Hebrew": @"IWR",
      @"Javanese": @"JAV",
      @"Yiddish": @"JII",
      @"Japanese": @"JAN",
      @"Judezmo": @"JUD",
      @"Jula": @"JUL",
      @"Kabardian": @"KAB",
      @"Kachchi": @"KAC",
      @"Kalenjin": @"KAL",
      @"Kannada": @"KAN",
      @"Karachay": @"KAR",
      @"Georgian": @"KAT",
      @"Kazakh": @"KAZ",
      @"Kebena": @"KEB",
      @"Khutsuri Georgian": @"KGE",
      @"Khakass": @"KHA",
      @"Khanty-Kazim": @"KHK",
      @"Khmer": @"KHM",
      @"Khanty-Shurishkar": @"KHS",
      @"Khanty-Vakhi": @"KHV",
      @"Khowar": @"KHW",
      @"Kikuyu": @"KIK",
      @"Kirghiz": @"KIR",
      @"Kisii": @"KIS",
      @"Kokni": @"KKN",
      @"Kalmyk": @"KLM",
      @"Kamba": @"KMB",
      @"Kumaoni": @"KMN",
      @"Komo": @"KMO",
      @"Komso": @"KMS",
      @"Kanuri": @"KNR",
      @"Kodagu": @"KOD",
      @"Korean Old Hangul": @"KOH",
      @"Konkani": @"KOK",
      @"Kikongo": @"KON",
      @"Komi-Permyak": @"KOP",
      @"Korean": @"KOR",
      @"Komi-Zyrian": @"KOZ",
      @"Kpelle": @"KPL",
      @"Krio": @"KRI",
      @"Karakalpak": @"KRK",
      @"Karelian": @"KRL",
      @"Karaim": @"KRM",
      @"Karen": @"KRN",
      @"Koorete": @"KRT",
      @"Kashmiri": @"KSH",
      @"Khasi": @"KSI",
      @"Kildin Sami": @"KSM",
      @"Kui": @"KUI",
      @"Kulvi": @"KUL",
      @"Kumyk": @"KUM",
      @"Kurdish": @"KUR",
      @"Kurukh": @"KUU",
      @"Kuy": @"KUY",
      @"Koryak": @"KYK",
      @"Ladin": @"LAD",
      @"Lahuli": @"LAH",
      @"Lak": @"LAK",
      @"Lambani": @"LAM",
      @"Lao": @"LAO",
      @"Latin": @"LAT",
      @"Laz": @"LAZ",
      @"L-Cree": @"LCR",
      @"Ladakhi": @"LDK",
      @"Lezgi": @"LEZ",
      @"Lingala": @"LIN",
      @"Low Mari": @"LMA",
      @"Limbu": @"LMB",
      @"Lomwe": @"LMW",
      @"Lower Sorbian": @"LSB",
      @"Lule Sami": @"LSM",
      @"Lithuanian": @"LTH",
      @"Luxembourgish": @"LTZ",
      @"Luba": @"LUB",
      @"Luganda": @"LUG",
      @"Luhya": @"LUH",
      @"Luo": @"LUO",
      @"Latvian": @"LVI",
      @"Majang": @"MAJ",
      @"Makua": @"MAK",
      @"Malayalam Traditional": @"MAL",
      @"Mansi": @"MAN",
      @"Mapudungun": @"MAP",
      @"Marathi": @"MAR",
      @"Marwari": @"MAW",
      @"Mbundu": @"MBN",
      @"Manchu": @"MCH",
      @"Moose Cree": @"MCR",
      @"Mende": @"MDE",
      @"Me'en": @"MEN",
      @"Mizo": @"MIZ",
      @"Macedonian": @"MKD",
      @"Male": @"MLE",
      @"Malagasy": @"MLG",
      @"Malinke": @"MLN",
      @"Malayalam Reformed": @"MLR",
      @"Malay": @"MLY",
      @"Mandinka": @"MND",
      @"Mongolian": @"MNG",
      @"Manipuri": @"MNI",
      @"Maninka": @"MNK",
      @"Manx Gaelic": @"MNX",
      @"Mohawk": @"MOH",
      @"Moksha": @"MOK",
      @"Moldavian": @"MOL",
      @"Mon": @"MON",
      @"Moroccan": @"MOR",
      @"Maori": @"MRI",
      @"Maithili": @"MTH",
      @"Maltese": @"MTS",
      @"Mundari": @"MUN",
      @"Naga-Assamese": @"NAG",
      @"Nanai": @"NAN",
      @"Naskapi": @"NAS",
      @"N-Cree": @"NCR",
      @"Ndebele": @"NDB",
      @"Ndonga": @"NDG",
      @"Nepali": @"NEP",
      @"Newari": @"NEW",
      @"Nagari": @"NGR",
      @"Norway House Cree": @"NHC",
      @"Nisi": @"NIS",
      @"Niuean": @"NIU",
      @"Nkole": @"NKL",
      @"N'Ko": @"NKO",
      @"Dutch": @"NLD",
      @"Nogai": @"NOG",
      @"Norwegian": @"NOR",
      @"Northern Sami": @"NSM",
      @"Northern Tai": @"NTA",
      @"Esperanto": @"NTO",
      @"Nynorsk": @"NYN",
      @"Occitan": @"OCI",
      @"Oji-Cree": @"OCR",
      @"Ojibway": @"OJB",
      @"Odia(formerly Oriya)": @"ORI",
      @"Oromo": @"ORO",
      @"Ossetian": @"OSS",
      @"Palestinian Aramaic": @"PAA",
      @"Pali": @"PAL",
      @"Punjabi": @"PAN",
      @"Palpa": @"PAP",
      @"Pashto": @"PAS",
      @"Polytonic Greek": @"PGR",
      @"Filipino": @"PIL",
      @"Palaung": @"PLG",
      @"Polish": @"PLK",
      @"Provencal": @"PRO",
      @"Portuguese": @"PTG",
      @"Chin": @"QIN",
      @"Rajasthani": @"RAJ",
      @"R-Cree": @"RCR",
      @"Russian Buriat": @"RBU",
      @"Riang": @"RIA",
      @"Rhaeto-Romanic": @"RMS",
      @"Romanian": @"ROM",
      @"Romany": @"ROY",
      @"Rusyn": @"RSY",
      @"Ruanda": @"RUA",
      @"Russian": @"RUS",
      @"Sadri": @"SAD",
      @"Sanskrit": @"SAN",
      @"Santali": @"SAT",
      @"Sayisi": @"SAY",
      @"Sekota": @"SEK",
      @"Selkup": @"SEL",
      @"Sango": @"SGO",
      @"Shan": @"SHN",
      @"Sibe": @"SIB",
      @"Sidamo": @"SID",
      @"Silte Gurage": @"SIG",
      @"Skolt Sami": @"SKS",
      @"Slovak": @"SKY",
      @"Slavey": @"SLA",
      @"Slovenian": @"SLV",
      @"Somali": @"SML",
      @"Samoan": @"SMO",
      @"Sena": @"SNA",
      @"Sindhi": @"SND",
      @"Sinhalese": @"SNH",
      @"Soninke": @"SNK",
      @"Sodo Gurage": @"SOG",
      @"Sotho": @"SOT",
      @"Albanian": @"SQI",
      @"Serbian": @"SRB",
      @"Saraiki": @"SRK",
      @"Serer": @"SRR",
      @"South Slavey": @"SSL",
      @"Southern Sami": @"SSM",
      @"Suri": @"SUR",
      @"Svan": @"SVA",
      @"Swedish": @"SVE",
      @"Swadaya Aramaic": @"SWA",
      @"Swahili": @"SWK",
      @"Swazi": @"SWZ",
      @"Sutu": @"SXT",
      @"Syriac": @"SYR",
      @"Tabasaran": @"TAB",
      @"Tajiki": @"TAJ",
      @"Tamil": @"TAM",
      @"Tatar": @"TAT",
      @"TH-Cree": @"TCR",
      @"Telugu": @"TEL",
      @"Tongan": @"TGN",
      @"Tigre": @"TGR",
      @"Tigrinya": @"TGY",
      @"Thai": @"THA",
      @"Tahitian": @"THT",
      @"Tibetan": @"TIB",
      @"Turkmen": @"TKM",
      @"Temne": @"TMN",
      @"Tswana": @"TNA",
      @"Tundra Nenets": @"TNE",
      @"Tonga": @"TNG",
      @"Todo": @"TOD",
      @"Turkish": @"TRK",
      @"Tsonga": @"TSG",
      @"Turoyo Aramaic": @"TUA",
      @"Tulu": @"TUL",
      @"Tuvin": @"TUV",
      @"Twi": @"TWI",
      @"Udmurt": @"UDM",
      @"Ukrainian": @"UKR",
      @"Urdu": @"URD",
      @"Upper Sorbian": @"USB",
      @"Uyghur": @"UYG",
      @"Uzbek": @"UZB",
      @"Venda": @"VEN",
      @"Vietnamese": @"VIT",
      @"Wa": @"WA",
      @"Wagdi": @"WAG",
      @"West-Cree": @"WCR",
      @"Welsh": @"WEL",
      @"Wolof": @"WLF",
      @"Tai Lue": @"XBD",
      @"Xhosa": @"XHS",
      @"Yakut": @"YAK",
      @"Yoruba": @"YBA",
      @"Y-Cree": @"YCR",
      @"Yi Classic": @"YIC",
      @"Yi Modern": @"YIM",
      @"Chinese Hong Kong": @"ZHH",
      @"Chinese Phonetic": @"ZHP",
      @"Chinese Simplified": @"ZHS",
      @"Chinese Traditional": @"ZHT",
      @"Zande": @"ZND",
      @"Zulu": @"ZUL",

      };
    
    NSString * languageTrimed = [language stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * key in languageFullNameMapping) {
        NSString * value = [languageFullNameMapping objectForKey:key];
        if ([value compare:languageTrimed options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return key;
    }
    return language;
}

NSString * OTGetFeatureFullName(NSString * feature) {
    NSDictionary<NSString*, NSString*> * featuresFullNameMapping =
    @{
      @"aalt": @"Access All Alternates",
      @"abvf": @"Above-base Forms",
      @"abvm": @"Above-base Mark Positioning",
      @"abvs": @"Above-base Substitutions",
      @"afrc": @"Alternative Fractions",
      @"akhn": @"Akhands",
      @"blwf": @"Below-base Forms",
      @"blwm": @"Below-base Mark Positioning",
      @"blws": @"Below-base Substitutions",
      @"calt": @"Contextual Alternates",
      @"case": @"Case-Sensitive Forms",
      @"ccmp": @"Glyph Composition / Decomposition",
      @"cfar": @"Conjunct Form After Ro",
      @"cjct": @"Conjunct Forms",
      @"clig": @"Contextual Ligatures",
      @"cpct": @"Centered CJK Punctuation",
      @"cpsp": @"Capital Spacing",
      @"cswh": @"Contextual Swash",
      @"curs": @"Cursive Positioning",
      @"cv01-cv99": @"Character Variants",
      @"c2pc": @"Petite Capitals From Capitals",
      @"c2sc": @"Small Capitals From Capitals",
      @"dist": @"Distances",
      @"dlig": @"Discretionary Ligatures",
      @"dnom": @"Denominators",
      @"expt": @"Expert Forms",
      @"falt": @"Final Glyph on Line Alternates",
      @"fin2": @"Terminal Forms #2",
      @"fin3": @"Terminal Forms #3",
      @"fina": @"Terminal Forms",
      @"frac": @"Fractions",
      @"fwid": @"Full Widths",
      @"half": @"Half Forms",
      @"haln": @"Halant Forms",
      @"halt": @"Alternate Half Widths",
      @"hist": @"Historical Forms",
      @"hkna": @"Horizontal Kana Alternates",
      @"hlig": @"Historical Ligatures",
      @"hngl": @"Hangul",
      @"hojo": @"Hojo Kanji Forms (JIS X 0212-1990 Kanji Forms)",
      @"hwid": @"Half Widths",
      @"init": @"Initial Forms",
      @"isol": @"Isolated Forms",
      @"ital": @"Italics",
      @"jalt": @"Justification Alternates",
      @"jp78": @"JIS78 Forms",
      @"jp83": @"JIS83 Forms",
      @"jp90": @"JIS90 Forms",
      @"jp04": @"JIS2004 Forms",
      @"kern": @"Kerning",
      @"lfbd": @"Left Bounds",
      @"liga": @"Standard Ligatures",
      @"ljmo": @"Leading Jamo Forms",
      @"lnum": @"Lining Figures",
      @"locl": @"Localized Forms",
      @"ltra": @"Left-to-right alternates",
      @"ltrm": @"Left-to-right mirrored forms",
      @"mark": @"Mark Positioning",
      @"med2": @"Medial Forms #2",
      @"medi": @"Medial Forms",
      @"mgrk": @"Mathematical Greek",
      @"mkmk": @"Mark to Mark Positioning",
      @"mset": @"Mark Positioning via Substitution",
      @"nalt": @"Alternate Annotation Forms",
      @"nlck": @"NLC Kanji Forms",
      @"nukt": @"Nukta Forms",
      @"numr": @"Numerators",
      @"onum": @"Oldstyle Figures",
      @"opbd": @"Optical Bounds",
      @"ordn": @"Ordinals",
      @"ornm": @"Ornaments",
      @"palt": @"Proportional Alternate Widths",
      @"pcap": @"Petite Capitals",
      @"pkna": @"Proportional Kana",
      @"pnum": @"Proportional Figures",
      @"pref": @"Pre-Base Forms",
      @"pres": @"Pre-base Substitutions",
      @"pstf": @"Post-base Forms",
      @"psts": @"Post-base Substitutions",
      @"pwid": @"Proportional Widths",
      @"qwid": @"Quarter Widths",
      @"rand": @"Randomize",
      @"rkrf": @"Rakar Forms",
      @"rlig": @"Required Ligatures",
      @"rphf": @"Reph Forms",
      @"rtbd": @"Right Bounds",
      @"rtla": @"Right-to-left alternates",
      @"rtlm": @"Right-to-left mirrored forms",
      @"ruby": @"Ruby Notation Forms",
      @"salt": @"Stylistic Alternates",
      @"sinf": @"Scientific Inferiors",
      @"size": @"Optical size",
      @"smcp": @"Small Capitals",
      @"smpl": @"Simplified Forms",
      @"ss01": @"Stylistic Set 1",
      @"ss02": @"Stylistic Set 2",
      @"ss03": @"Stylistic Set 3",
      @"ss04": @"Stylistic Set 4",
      @"ss05": @"Stylistic Set 5",
      @"ss06": @"Stylistic Set 6",
      @"ss07": @"Stylistic Set 7",
      @"ss08": @"Stylistic Set 8",
      @"ss09": @"Stylistic Set 9",
      @"ss10": @"Stylistic Set 10",
      @"ss11": @"Stylistic Set 11",
      @"ss12": @"Stylistic Set 12",
      @"ss13": @"Stylistic Set 13",
      @"ss14": @"Stylistic Set 14",
      @"ss15": @"Stylistic Set 15",
      @"ss16": @"Stylistic Set 16",
      @"ss17": @"Stylistic Set 17",
      @"ss18": @"Stylistic Set 18",
      @"ss19": @"Stylistic Set 19",
      @"ss20": @"Stylistic Set 20",
      @"subs": @"Subscript",
      @"sups": @"Superscript",
      @"swsh": @"Swash",
      @"titl": @"Titling",
      @"tjmo": @"Trailing Jamo Forms",
      @"tnam": @"Traditional Name Forms",
      @"tnum": @"Tabular Figures",
      @"trad": @"Traditional Forms",
      @"twid": @"Third Widths",
      @"unic": @"Unicase",
      @"valt": @"Alternate Vertical Metrics",
      @"vatu": @"Vattu Variants",
      @"vert": @"Vertical Writing",
      @"vhal": @"Alternate Vertical Half Metrics",
      @"vjmo": @"Vowel Jamo Forms",
      @"vkna": @"Vertical Kana Alternates",
      @"vkrn": @"Vertical Kerning",
      @"vpal": @"Proportional Alternate Vertical Metrics",
      @"vrt2": @"Vertical Alternates and Rotation",
      @"zero": @"Slashed Zero",
    };
    
    NSString * featureTrimed = [feature stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * key in featuresFullNameMapping) {
        NSString * value = [featuresFullNameMapping objectForKey:key];
        if ([key compare:featureTrimed options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return value;
    }
    return feature;
}


NSString * OTGetGSUBLookupName(NSUInteger lookupType) {
    NSArray<NSString *> * names =
    @[
      @"Single Substitution",
      @"Multiple Substitution",
      @"Alternate Substitution",
      @"Ligature Substitution",
      @"Contextual Substitution",
      @"Chaining Contextual Substitution",
      @"Externsion Substitution",
      @"Resverse Chaining Contextual Single Substitution"
      ];
    if ((lookupType - 1) >= names.count)
        return [NSString stringWithFormat:@"Unknown Lookup Type %ld", lookupType];
    return [names objectAtIndex:lookupType - 1];
}

NSString * OTGetGPOSLookupName(NSUInteger lookupType) {
    NSArray<NSString *> * names =
    @[
      @"Single Adjustment",
      @"Pair Adjustment",
      @"Cursive Attachment",
      @"MarkToBase Attachment",
      @"MarkToLigature Attachment",
      @"MarkToMark Attachment",
      @"Context Positioning",
      @"Chained Context Positioning",
      @"Extension Positioning",
      ];
    if ((lookupType - 1) >= names.count)
        return [NSString stringWithFormat:@"Unknown Lookup Type %ld", lookupType];
    return [names objectAtIndex:lookupType - 1];
}

NSString * OTGetLookupFlagDescription(uint16_t flag) {
    
    NSMutableArray<NSString*> * description = [[NSMutableArray<NSString*> alloc] init];
    
    [description addObject:[NSString stringWithFormat:@"0x%04x", flag]];
    [description addObject:[NSString stringWithFormat:@"RightToLeft: %@", (flag & 0x0001)? @"YES": @"NO"]];
    [description addObject:[NSString stringWithFormat:@"IgnoreBaseGlyphs: %@", (flag & 0x0002)? @"YES": @"NO"]];
    [description addObject:[NSString stringWithFormat:@"IgnoreLigatures: %@", (flag & 0x0004)? @"YES": @"NO"]];
    [description addObject:[NSString stringWithFormat:@"IgnoreMarks: %@", (flag & 0x0008)? @"YES": @"NO"]];
    [description addObject:[NSString stringWithFormat:@"UseMarkFilteringSet: %@", (flag & 0x0010)? @"YES": @"NO"]];
    [description addObject:[NSString stringWithFormat:@"MarkAttachmentType: 0x%02x", (flag >> 8)]];
    
    return [description componentsJoinedByString:@", "];
}


NSString * PostGetMacintoshGlyphName(NSUInteger index) {
    NSArray<NSString*> *names =
    @[
      @".notdef",
      @".null",
      @"nonmarkingreturn",
      @"space",
      @"exclam",
      @"quotedbl",
      @"numbersign",
      @"dollar",
      @"percent",
      @"ampersand",
      @"quotesingle",
      @"parenleft",
      @"parenright",
      @"asterisk",
      @"plus",
      @"comma",
      @"hyphen",
      @"period",
      @"slash",
      @"zero",
      @"one",
      @"two",
      @"three",
      @"four",
      @"five",
      @"six",
      @"seven",
      @"eight",
      @"nine",
      @"colon",
      @"semicolon",
      @"less",
      @"equal",
      @"greater",
      @"question",
      @"at",
      @"A",
      @"B",
      @"C",
      @"D",
      @"E",
      @"F",
      @"G",
      @"H",
      @"I",
      @"J",
      @"K",
      @"L",
      @"M",
      @"N",
      @"O",
      @"P",
      @"Q",
      @"R",
      @"S",
      @"T",
      @"U",
      @"V",
      @"W",
      @"X",
      @"Y",
      @"Z",
      @"bracketleft",
      @"backslash",
      @"bracketright",
      @"asciicircum",
      @"underscore",
      @"grave",
      @"a",
      @"b",
      @"c",
      @"d",
      @"e",
      @"f",
      @"g",
      @"h",
      @"i",
      @"j",
      @"k",
      @"l",
      @"m",
      @"n",
      @"o",
      @"p",
      @"q",
      @"r",
      @"s",
      @"t",
      @"u",
      @"v",
      @"w",
      @"x",
      @"y",
      @"z",
      @"braceleft",
      @"bar",
      @"braceright",
      @"asciitilde",
      @"Adieresis",
      @"Aring",
      @"Ccedilla",
      @"Eacute",
      @"Ntilde",
      @"Odieresis",
      @"Udieresis",
      @"aacute",
      @"agrave",
      @"acircumflex",
      @"adieresis",
      @"atilde",
      @"aring",
      @"ccedilla",
      @"eacute",
      @"egrave",
      @"ecircumflex",
      @"edieresis",
      @"iacute",
      @"igrave",
      @"icircumflex",
      @"idieresis",
      @"ntilde",
      @"oacute",
      @"ograve",
      @"ocircumflex",
      @"odieresis",
      @"otilde",
      @"uacute",
      @"ugrave",
      @"ucircumflex",
      @"udieresis",
      @"dagger",
      @"degree",
      @"cent",
      @"sterling",
      @"section",
      @"bullet",
      @"paragraph",
      @"germandbls",
      @"registered",
      @"copyright",
      @"trademark",
      @"acute",
      @"dieresis",
      @"notequal",
      @"AE",
      @"Oslash",
      @"infinity",
      @"plusminus",
      @"lessequal",
      @"greaterequal",
      @"yen",
      @"mu",
      @"partialdiff",
      @"summation",
      @"product",
      @"pi",
      @"integral",
      @"ordfeminine",
      @"ordmasculine",
      @"Omega",
      @"ae",
      @"oslash",
      @"questiondown",
      @"exclamdown",
      @"logicalnot",
      @"radical",
      @"florin",
      @"approxequal",
      @"Delta",
      @"guillemotleft",
      @"guillemotright",
      @"ellipsis",
      @"nonbreakingspace",
      @"Agrave",
      @"Atilde",
      @"Otilde",
      @"OE",
      @"oe",
      @"endash",
      @"emdash",
      @"quotedblleft",
      @"quotedblright",
      @"quoteleft",
      @"quoteright",
      @"divide",
      @"lozenge",
      @"ydieresis",
      @"Ydieresis",
      @"fraction",
      @"currency",
      @"guilsinglleft",
      @"guilsinglright",
      @"fi",
      @"fl",
      @"daggerdbl",
      @"periodcentered",
      @"quotesinglbase",
      @"quotedblbase",
      @"perthousand",
      @"Acircumflex",
      @"Ecircumflex",
      @"Aacute",
      @"Edieresis",
      @"Egrave",
      @"Iacute",
      @"Icircumflex",
      @"Idieresis",
      @"Igrave",
      @"Oacute",
      @"Ocircumflex",
      @"apple",
      @"Ograve",
      @"Uacute",
      @"Ucircumflex",
      @"Ugrave",
      @"dotlessi",
      @"circumflex",
      @"tilde",
      @"macron",
      @"breve",
      @"dotaccent",
      @"ring",
      @"cedilla",
      @"hungarumlaut",
      @"ogonek",
      @"caron",
      @"Lslash",
      @"lslash",
      @"Scaron",
      @"scaron",
      @"Zcaron",
      @"zcaron",
      @"brokenbar",
      @"Eth",
      @"eth",
      @"Yacute",
      @"yacute",
      @"Thorn",
      @"thorn",
      @"minus",
      @"multiply",
      @"onesuperior",
      @"twosuperior",
      @"threesuperior",
      @"onehalf",
      @"onequarter",
      @"threequarters",
      @"franc",
      @"Gbreve",
      @"gbreve",
      @"Idotaccent",
      @"Scedilla",
      @"scedilla",
      @"Cacute",
      @"cacute",
      @"Ccaron",
      @"ccaron",
      @"dcroat",
      ];
    return [names objectAtIndex:index];
}
NSArray<UnicodeBlock*> * OS2GetUnicodeRanges(uint32_t range1, uint32_t range2, uint32_t range3, uint32_t range4) {
    NSArray<NSArray<NSString*> *> * allBlockNames
    = @[@[@"Basic Latin"],
        @[@"Latin-1 Supplement"],
        @[@"Latin Extended-A"],
        @[@"Latin Extended-B"],
        @[@"IPA Extensions", @"Phonetic Extensions", @"Phonetic Extensions Supplement"],
        @[@"Spacing Modifier Letters", @"Modifier Tone Letters"],
        @[@"Combining Diacritical Marks", @"Combining Diacritical Marks Supplement"],
        @[@"Greek and Coptic"],
        @[@"Coptic"],
        @[@"Cyrillic", @"Cyrillic Supplement", @"Cyrillic Extended-A", @"Cyrillic Extended-B"],
        @[@"Armenian"],
        @[@"Hebrew"],
        @[@"Vai"],
        @[@"Arabic", @"Arabic Supplement"],
        @[@"NKo"],
        @[@"Devanagari"],
        @[@"Bengali"],
        @[@"Gurmukhi"],
        @[@"Gujarati"],
        @[@"Oriya"],
        @[@"Tamil"],
        @[@"Telugu"],
        @[@"Kannada"],
        @[@"Malayalam"],
        @[@"Thai"],
        @[@"Lao"],
        @[@"Georgian", @"Georgian Supplement"],
        @[@"Balinese"],
        @[@"Hangul Jamo"],
        @[@"Latin Extended Additional", @"Latin Extended-C", @"Latin Extended-D"],
        @[@"Greek Extended"],
        @[@"General Punctuation", @"Supplemental Punctuation"],
        @[@"Superscripts And Subscripts"],
        @[@"Currency Symbols"],
        @[@"Combining Diacritical Marks For Symbols"],
        @[@"Letterlike Symbols"],
        @[@"Number Forms"],
        @[@"Arrows", @"Supplemental Arrows-A", @"Supplemental Arrows-B", @"Miscellaneous Symbols and Arrows"],
        @[@"Mathematical Operators", @"Supplemental Mathematical Operators", @"Miscellaneous Mathematical Symbols-A", @"Miscellaneous Mathematical Symbols-B"],
        @[@"Miscellaneous Technical"],
        @[@"Control Pictures"],
        @[@"Optical Character Recognition"],
        @[@"Enclosed Alphanumerics"],
        @[@"Box Drawing"],
        @[@"Block Elements"],
        @[@"Geometric Shapes"],
        @[@"Miscellaneous Symbols"],
        @[@"Dingbats"],
        @[@"CJK Symbols And Punctuation"],
        @[@"Hiragana"],
        @[@"Katakana", @"Katakana Phonetic Extensions"],
        @[@"Bopomofo", @"Bopomofo Extended"],
        @[@"Hangul Compatibility Jamo"],
        @[@"Phags-pa"],
        @[@"Enclosed CJK Letters And Months"],
        @[@"CJK Compatibility"],
        @[@"Hangul Syllables"],
        @[@"High Surrogates", @"High Private Use Surrogates", @"Low Surrogates"],
        @[@"Phoenician"],
        @[@"CJK Unified Ideographs", @"CJK Radicals Supplement", @"Kangxi Radicals", @"Ideographic Description Characters", @"CJK Unified Ideographs Extension A", @"CJK Unified Ideographs Extension B", @"Kanbun"],
        @[@"Private Use Area"],
        @[@"CJK Strokes", @"CJK Compatibility Ideographs", @"CJK Compatibility Ideographs Supplement"],
        @[@"Alphabetic Presentation Forms"],
        @[@"Arabic Presentation Forms-A"],
        @[@"Combining Half Marks"],
        @[@"Vertical Forms", @"CJK Compatibility Forms"],
        @[@"Small Form Variants"],
        @[@"Arabic Presentation Forms-B"],
        @[@"Halfwidth And Fullwidth Forms"],
        @[@"Specials"],
        @[@"Tibetan"],
        @[@"Syriac"],
        @[@"Thaana"],
        @[@"Sinhala"],
        @[@"Myanmar"],
        @[@"Ethiopic", @"Ethiopic Supplement", @"Ethiopic Extended"],
        @[@"Cherokee"],
        @[@"Unified Canadian Aboriginal Syllabics"],
        @[@"Ogham"],
        @[@"Runic"],
        @[@"Khmer", @"Khmer Symbols"],
        @[@"Mongolian"],
        @[@"Braille Patterns"],
        @[@"Yi Syllables", @"Yi Radicals"],
        @[@"Tagalog", @"Hanunoo", @"Buhid", @"Tagbanwa"],
        @[@"Old Italic"],
        @[@"Gothic"],
        @[@"Deseret"],
        @[@"Byzantine Musical Symbols", @"Musical Symbols", @"Ancient Greek Musical Notation"],
        @[@"Mathematical Alphanumeric Symbols"],
        @[@"Supplementary Private Use Area-A", @"Supplementary Private Use Area-B"],
        @[@"Variation Selectors", @"Variation Selectors Supplement"],
        @[@"Tags"],
        @[@"Limbu"],
        @[@"Tai Le"],
        @[@"New Tai Lue"],
        @[@"Buginese"],
        @[@"Glagolitic"],
        @[@"Tifinagh"],
        @[@"Yijing Hexagram Symbols"],
        @[@"Syloti Nagri"],
        @[@"Linear B Syllabary", @"Linear B Ideograms", @"Aegean Numbers"],
        @[@"Ancient Greek Numbers"],
        @[@"Ugaritic"],
        @[@"Old Persian"],
        @[@"Shavian"],
        @[@"Osmanya"],
        @[@"Cypriot Syllabary"],
        @[@"Kharoshthi"],
        @[@"Tai Xuan Jing Symbols"],
        @[@"Cuneiform", @"Cuneiform Numbers and Punctuation"],
        @[@"Counting Rod Numerals"],
        @[@"Sundanese"],
        @[@"Lepcha"],
        @[@"Ol Chiki"],
        @[@"Saurashtra"],
        @[@"Kayah Li"],
        @[@"Rejang"],
        @[@"Cham"],
        @[@"Ancient Symbols"],
        @[@"Phaistos Disc"],
        @[@"Carian", @"Lycian", @"Lydian"],
        @[@"Domino Tiles", @"Mahjong Tiles"],
        ];
    
    NSMutableArray<NSString*> * blockNames = [[NSMutableArray<NSString*> alloc] init];
    uint32_t range[] = {range1, range2, range3, range4};
    for (int i = 0; i < allBlockNames.count; ++ i) {
        unsigned char k = i % 32;
        unsigned char f = i / 32;
        if (range[f] & (1 << k)) {
            [blockNames addObjectsFromArray:[allBlockNames objectAtIndex:i]];
        }
    }
    
    NSMutableArray<UnicodeBlock*> * blocks = [[NSMutableArray<UnicodeBlock*> alloc] init];
    for (NSString* blockName in blockNames) {
        [blocks addObject:[[UnicodeDatabase standardDatabase] unicodeBlockWithName:blockName]];
    }
    return blocks;
}

NSArray<NSString *> * OS2GetCodePageRanges(uint32_t range1, uint32_t range2) {
    NSArray<NSArray<NSString*> *> * allCodePages
    = @[
        @[@"1252"	,@"Latin 1"],
        @[@"1250"	,@"Latin 2: Eastern Europe"],
        @[@"1251"	,@"Cyrillic"],
        @[@"1253"	,@"Greek"],
        @[@"1254"	,@"Turkish"],
        @[@"1255"	,@"Hebrew"],
        @[@"1256"	,@"Arabic"],
        @[@"1257"	,@"Windows Baltic"],
        @[@"1258"	,@"Vietnamese"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"udef" 	,@"Reserved for Alternate ANSI"],
        @[@"874"	,@"Thai"],
        @[@"932"	,@"JIS/Japan"],
        @[@"936"	,@"Chinese: Simplified chars--PRC and Singapore"],
        @[@"949"	,@"Korean Wansung"],
        @[@"950"	,@"Chinese: Traditional chars--Taiwan and Hong Kong"],
        @[@"1361"	,@"Korean Johab"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Reserved for Alternate ANSI & OEM"],
        @[@"udef" 	,@"Macintosh Character Set (US Roman)"],
        @[@"udef" 	,@"OEM Character Set"],
        @[@"udef" 	,@"Symbol Character Set"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"udef" 	,@"Reserved for OEM"],
        @[@"869"	,@"IBM Greek"],
        @[@"866"	,@"MS-DOS Russian"],
        @[@"865"	,@"MS-DOS Nordic"],
        @[@"864"	,@"Arabic"],
        @[@"863"	,@"MS-DOS Canadian French"],
        @[@"862"	,@"Hebrew"],
        @[@"861"	,@"MS-DOS Icelandic"],
        @[@"860"	,@"MS-DOS Portuguese"],
        @[@"857"	,@"IBM Turkish"],
        @[@"855"	,@"IBM Cyrillic; primarily Russian"],
        @[@"852"	,@"Latin 2"],
        @[@"775"	,@"MS-DOS Baltic"],
        @[@"737"	,@"Greek; former 437 G"],
        @[@"708"	,@"Arabic; ASMO 708"],
        @[@"850"	,@"WE/Latin 1"],
        @[@"437"	,@"US"],
        ];
    
    NSMutableArray<NSString*> * codePages = [[NSMutableArray<NSString*> alloc] init];
    
    uint32_t range[] = {range1, range2};
    for (int i = 0; i < allCodePages.count; ++ i) {
        unsigned char k = i % 32;
        unsigned char f = i / 32;
        if (range[f] & (1 << k)) {
            NSInteger  code = [[[allCodePages objectAtIndex:i] objectAtIndex:0] integerValue];
            NSString * name = [[allCodePages objectAtIndex:i] objectAtIndex:1];
            if (code)
                [codePages addObject:[NSString stringWithFormat:@"%@ (%ld)", name, code]];
            else
                [codePages addObject:name];
        }
    }
    return codePages;
}
