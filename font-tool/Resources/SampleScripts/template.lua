function table.tostring( tbl )
  local result = {}
  for k, v in pairs(tbl) do
     table.insert(result, k .. "=" .. v)
  end
  return "{" .. table.concat( result, ", " ) .. "}"
end

function filterFont(font)
   print(font.familyName .. ' ' .. font.styleName .. ' : ' )
   print('   PS Name = ' .. font.postscriptName)
   print('   Num Glyphs = ' .. font.numGlyphs)
   print('   UPEM = ' .. font.UPEM)
   print('   createdDate = ' .. font.createdDate)
   print('   modifiedDate = ' .. font.modifiedDate)
   print('   Localized Family Names = ' .. table.tostring(font.localizedFamilyNames))
   print('   Localized Style Names = ' .. table.tostring(font.localizedStyleNames))
   print('   Localized Full Names = ' .. table.tostring(font.localizedFullNames))
   print('   format = ' .. font.format)
   print('   isCID = ' .. tostring(font.isCID))
   print('   vender = ' .. font.vender)
   print('   version = ' .. font.version)
   return true
end
