function nametabletostring(tbl)
  local result = {}
  for k, v in pairs(tbl) do
     table.insert(result, k .. "=" .. v)
  end
  return "{" .. table.concat( result, ", " ) .. "}"
end

function otsettostring(set)
  local result = {}
  for k, _ in pairs(set) do
     table.insert(result, k)
  end
  return "{" .. table.concat( result, ", " ) .. "}"   
end

function otfeaturestostring(features)
  local result = {}
  for feat, r in pairs(features) do
     table.insert(result, feat .. (r and '*' or ''))
  end
  return "{" .. table.concat( result, ", " ) .. "}"      
end

function arraytostring(set)
  local result = {}
  for _, v in pairs(set) do
     table.insert(result, v)
  end
  return "{" .. table.concat(result, ", ") .. "}"   
end


function filterFont(font)
   print(font.postscriptName)
   print('   Num Glyphs = ' .. font.numGlyphs)
   print('   UPEM = ' .. font.UPEM)
   print('   CreatedDate = ' .. font.createdDate)
   print('   ModifiedDate = ' .. font.modifiedDate)

   -- font.otScripts is a set, which key is the script name, value is true
   -- font.otLanguages is a set, which key is the language name, value is true
   -- font.otFeatures is a set, which key the feature name, value is true if the feature
   -- is required, false if optional
   print('   IsOpenTypeVariation = ' .. tostring(font.isOpenTypeVariation))
   print('   IsAdobeMultiMaster = ' .. tostring(font.isAdobeMultiMaster))
   print('   OpenType Scripts = ' .. otsettostring(font.otScripts))
   print('   OpenType Languages = ' .. otsettostring(font.otLanguages))
   print('   OpenType Features = ' .. otfeaturestostring(font.otFeatures))
   
   -- font.localizedFamilyNames/localizedStyleNames/localizedFullNames
   -- is a table which key is the language, value is the name
   print('   Family Name = ' .. font.familyName)
   print('   Style Name = ' .. font.styleName)
   print('   Localized Family Names = ' .. nametabletostring(font.localizedFamilyNames))
   print('   Localized Style Names = ' .. nametabletostring(font.localizedStyleNames))
   print('   Localized Full Names = ' .. nametabletostring(font.localizedFullNames))

   -- font.designLanguages is an array, which key is the index, value is the language
   print('   Design Lanuages = ' .. arraytostring(font.designLanguages))
   
   print('   Format = ' .. font.format)
   print('   IsCID = ' .. tostring(font.isCID))
   print('   Vender = ' .. font.vender)
   print('   Version = ' .. font.version)
   return true
end
