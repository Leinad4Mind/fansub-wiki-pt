--[[
 Copyright (c) 2012-2013, Leinad4Mind
 All rights reserved®.
 
 Um grande agradecimento a todos os meus amigos
 que sempre me apoiaram, e a toda a comunidade
 de anime portuguesa.
--]]

script_name = "Adicionar Itálicos"
script_description = "Adicionar itálicos nas linhas seleccionadas"
script_author = "Leinad4Mind"
script_version = "2.0"
script_modified = "15 de Outubro 2013"

require("re")

function add_italic(subs, sel)
  for _index_0 = 1, #sel do
    local i = sel[_index_0]
    local l = subs[i]
    local s = l.text
    if s and not re.match(s, "\\{[^}]*\\\\(?:i)\\d", re.ICASE) then
      if s:match("^%s*{") then
        l.text = s:gsub("^(%s*{)", "%1\\i1")
      else
        l.text = "{\\i1}" .. s .. "{\\i0}"
      end
      subs[i] = l
    end
  end
  return sel
end

return aegisub.register_macro(script_name, script_description, add_italic)