
// Localized String
#undef NSLocalizedString 
#ifdef DEBUG
#define NSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:(comment) table:nil]
#else
#define NSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:(key) table:nil]
#endif


// Debug macros
#ifdef DEBUG
#define _Log(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define _Log(s, ...) 
#endif
