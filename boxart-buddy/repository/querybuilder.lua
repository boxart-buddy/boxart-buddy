---@class QueryBuilder
local M = class({
    name = "QueryBuilder",
})

function M:new()
    self._select = {}
    self._from = nil
    self._joins = {}
    self._where = nil
    self._group = nil
    self._order = nil
    self._limit = nil
    self._offset = nil
    self._alias = nil
    self._with = nil
end

function M:select(...)
    local fields = { ... }
    for _, f in ipairs(fields) do
        table.insert(self._select, f)
    end
    return self
end

function M:from(tableName)
    self._from = tableName
    return self
end

function M:join(joinType, tableName, onClause)
    table.insert(self._joins, string.format("%s JOIN %s ON %s", joinType, tableName, onClause))
    return self
end

function M:where(clause)
    if self._where then
        self._where = "(" .. self._where .. ") AND (" .. clause .. ")"
    else
        self._where = clause
    end
    return self
end

function M:orderBy(orderClause)
    self._order = orderClause
    return self
end

function M:groupBy(groupClause)
    self._group = groupClause
    return self
end

function M:limit(n)
    self._limit = n
    return self
end

function M:offset(n)
    self._offset = n
    return self
end

function M:asSubquery(alias)
    self._alias = alias
    return self
end

function M:with(cte)
    self._with = cte
    return self
end

function M:getQuery()
    local parts = {}
    if self._with then
        table.insert(parts, self._with)
    end
    table.insert(parts, "SELECT " .. table.concat(self._select, ", "))
    if self._from then
        table.insert(parts, "FROM " .. self._from)
    end
    for _, join in ipairs(self._joins) do
        table.insert(parts, join)
    end
    if self._where then
        table.insert(parts, "WHERE " .. self._where)
    end
    if self._group then
        table.insert(parts, "GROUP BY " .. self._group)
    end
    if self._order then
        table.insert(parts, "ORDER BY " .. self._order)
    end
    if self._limit then
        table.insert(parts, "LIMIT " .. tostring(self._limit))
    end
    if self._offset then
        table.insert(parts, "OFFSET " .. tostring(self._offset))
    end

    local query = table.concat(parts, " ")
    if self._alias then
        return string.format("(%s) AS %s", query, self._alias)
    else
        return query
    end
end

function M:countQuery()
    local parts = {}
    if self._with then
        table.insert(parts, self._with)
    end
    table.insert(parts, "SELECT COUNT(*) as count")
    if self._from then
        table.insert(parts, "FROM " .. self._from)
    end
    for _, join in ipairs(self._joins) do
        table.insert(parts, join)
    end
    if self._where then
        table.insert(parts, "WHERE " .. self._where)
    end
    return table.concat(parts, " ")
end

---Converts a table {"one", "two"} into a string "('one', 'two')"
---@param tbl table
---@return string
function M:tableToSqlInList(tbl)
    local quoted = {}
    for _, v in ipairs(tbl) do
        table.insert(quoted, string.format("'%s'", v))
    end
    return "(" .. table.concat(quoted, ", ") .. ")"
end

--- Adds a WHERE ... IN (...) clause
---@param column string The column name or expression
---@param values table A list of values to include
---@return QueryBuilder
function M:whereIn(column, values)
    local listExpr = self:tableToSqlInList(values)
    return self:where(string.format("%s IN %s", column, listExpr))
end

---Adds a COALESCE(field1, field2, ...) expression to the SELECT clause with optional alias
---@param ... string
---@return QueryBuilder
function M:selectCoalesce(...)
    local args = { ... }
    local alias
    if type(args[#args]) == "table" then
        local opts = table.remove(args)
        alias = opts.alias
    end
    if #args > 0 then
        local expr = "COALESCE(" .. table.concat(args, ", ") .. ")"
        if alias then
            expr = expr .. " AS " .. alias
        end
        table.insert(self._select, expr)
    end
    return self
end

return M
