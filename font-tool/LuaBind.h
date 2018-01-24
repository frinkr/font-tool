#pragma once

#include <vector>
#include <list>
#include <map>
#include <set>

extern "C"{
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
}

#include "LuaBridge/LuaBridge.h"

// Codes token from falltergeist

// functions for for Luabridge bindings
namespace LuaBind {
    /**
     * Converts Lua list-like table to std containers like vector, list.
     */
    template <class T>
    T tableToList(const luabridge::LuaRef& table)
    {
        T list;
        if (table.isTable())
        {
            for (size_t i = 1, n = (size_t)table.length(); (i <= n && !table[i].isNil()); i++)
            {
                list.push_back(table[i]); // implicit conversion from luabridge::Proxy should be called here
            }
        }
        return list;
    }
        
    /**
     * Assigns values from containers like list/vector to Lua list-like Table.
     */
    template <class T>
    void listToTable(luabridge::LuaRef& table, const T& list)
    {
        for (auto el : list)
        {
            table.append(el);
        }
    }
    
    /**
     * Converts Lua list-like table to std containers like vector, list.
     */
    template <class T>
    T tableToSet(const luabridge::LuaRef& table)
    {
        typedef typename T::value_type U;
        T set;
        if (table.isTable())
        {
            for (size_t i = 1, n = (size_t)table.length(); (i <= n && !table[i].isNil()); i++)
            {
                set.insert(table[i].cast<U>()); // don't why implicit conversion from luabridge::Proxy is not called here
            }
        }
        return set;
    }
    
    /**
     * Assigns values from containers like list/vector to Lua list-like Table.
     */
    template <class T>
    void setToTable(luabridge::LuaRef& table, const T& set)
    {
        for (auto el : set)
        {
            table[el] = true;
        }
    }
    
    /**
     * Converts Lua table to std::map containers.
     */
    template <class T>
    T tableToMap(const luabridge::LuaRef& table)
    {
        typedef typename T::mapped_type V;
        
        T map;
        if (table.isTable())
        {
            for (luabridge::Iterator iter(table); !iter.isNil(); ++iter)
            {
                map[iter.key()] = iter.value().cast<V>(); // implicit conversion from LuaRefs should be called here
            }
        }
        return map;
    }
        
    /**
     * Assigns values from map containers to Lua Table.
     */
    template <class T>
    void mapToTable(luabridge::LuaRef& table, const T& map)
    {
        for (auto el : map)
        {
            table[el.first] = el.second;
        }
    }

}    

/**
 * Specializations for luabridge::Stack<T>.
 */
namespace luabridge
{
    /**
     * Stack specialization for std::vector.
     * Creates new table every time vector is returned to Lua and new vector from table other way around.
     */
    template<typename T>
    struct Stack<std::vector<T>>
    {
    public:
        static inline void push(lua_State* L, const std::vector<T>& vec)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::listToTable<std::vector<T>>(table, vec);
            table.push(L);
        }
        
        static inline std::vector<T> get(lua_State* L, int index)
        {
            return LuaBind::tableToList<std::vector<T>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::vector. Const reference version.
     */
    template<typename T>
    struct Stack<const std::vector<T>&>
    {
    public:
        static inline void push(lua_State* L, const std::vector<T>& vec)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::listToTable<std::vector<T>>(table, vec);
            table.push(L);
        }
        
        static inline std::vector<T> get(lua_State* L, int index)
        {
            return LuaBind::tableToList<std::vector<T>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::list. Converts list to Lua table and vice versa.
     */
    template<typename T>
    struct Stack<std::list<T>>
    {
    public:
        static inline void push(lua_State* L, const std::list<T>& list)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::listToTable<std::list<T>>(table, list);
            table.push(L);
        }
        
        static inline std::list<T> get(lua_State* L, int index)
        {
            return LuaBind::tableToList<std::list<T>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::list. Const ref version.
     */
    template<typename T>
    struct Stack<const std::list<T>&>
    {
    public:
        static inline void push(lua_State* L, const std::list<T>& list)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::listToTable<std::list<T>>(table, list);
            table.push(L);
        }
        
        static inline std::list<T> get(lua_State* L, int index)
        {
            return LuaBind::tableToList<std::list<T>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::set. Converts list to Lua table and vice versa.
     */
    template<typename T>
    struct Stack<std::set<T>>
    {
    public:
        static inline void push(lua_State* L, std::set<T> list)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::setToTable<std::set<T>>(table, list);
            table.push(L);
        }
        
        static inline std::set<T> get(lua_State* L, int index)
        {
            return LuaBind::tableToSet<std::set<T>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::list. Const ref version.
     */
    template<typename T>
    struct Stack<const std::set<T>&>
    {
    public:
        static inline void push(lua_State* L, const std::set<T>& list)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::setToTable<std::set<T>>(table, list);
            table.push(L);
        }
        
        static inline std::set<T> get(lua_State* L, int index)
        {
            return LuaBind::tableToSet<std::set<T>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::map. Converts map to Lua table and vice versa.
     */
    template<typename TK, typename TV>
    struct Stack<std::map<TK, TV>>
    {
    public:
        static inline void push(lua_State* L, const std::map<TK, TV>& map)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::mapToTable(table, map);
            table.push(L);
        }
        
        static inline std::map<TK, TV> get(lua_State* L, int index)
        {
            return LuaBind::tableToMap<std::map<TK, TV>>(LuaRef::fromStack(L, index));
        }
    };
    
    /**
     * Stack specialization for std::map. Const ref version.
     */
    template<typename TK, typename TV>
    struct Stack<const std::map<TK, TV>&>
    {
    public:
        static inline void push(lua_State* L, const std::map<TK, TV>& map)
        {
            auto table = LuaRef::newTable(L);
            LuaBind::mapToTable(table, map);
            table.push(L);
        }
        
        static inline std::map<TK, TV> get(lua_State* L, int index)
        {
            return LuaBind::tableToMap<std::map<TK, TV>>(LuaRef::fromStack(L, index));
        }
    };
}
