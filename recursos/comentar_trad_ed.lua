--[[
 Copyright (c) 2012-2013, Leinad4Mind
 All rights reserved®.
 
 Agradecimentos a FichteFoll e tophf pela ajuda nas expressões regulares
 E um obrigado especial ao Youka pela sua função AddTags que deu muito jeito.
 
 Um grande agradecimento a todos os meus amigos
 que sempre me apoiaram, e a toda a comunidade
 de anime portuguesa.
--]]

script_name = "Adicionar ou Remover Comentários"
script_description = "Colocar todas as linhas como comentários para se traduzir. E possibilidade de apagar todas as linhas dos comentários. Expressões aos Estilos ou Linhas Seleccionadas. Aconselhado para a versão 3.x"
script_author = "Youka, Leinad4Mind, Shimapan"
script_version = "3.0"
script_modified = "2013-11-13"

include("cleantags.lua")

--Cleantags do cleantags-autoload
function cleantags_subs(subtitles)
	local linescleaned = 0
	for i = 1, #subtitles do
		aegisub.progress.set(i * 100 / #subtitles)
		if subtitles[i].class == "dialogue" and not subtitles[i].comment and subtitles[i].text ~= "" then
			ntext = cleantags(subtitles[i].text)
			local nline = subtitles[i]
			nline.text = ntext
			subtitles[i] = nline
			linescleaned = linescleaned + 1
			aegisub.progress.task(linescleaned .. " linhas limpas")
		end
	end
end

--Recolhe nomes dos estilos
function collect_styles(subs)
	local n, styles = 0, {}
	for i=1, #subs do
		local sub = subs[i]
		if sub.class == "style" then
			n = n + 1
			styles[n] = sub.name
		end
	end
	return styles
end

--Configuração
function create_confi(subs)
	local styles = collect_styles(subs)
	local conf = {
		{
			class = "label",
			x = 1, y = 0, width = 5, height = 1,
			label = "\n...| Desenvolvido por Leinad4Mind |...",
		},
		{
			class = "label",
			x = 1, y = 2, width = 1, height = 1,
			label = "Seleccione:"
		},
		{
			class = "dropdown", name = "comment",
			x = 2, y = 2, width = 5, height = 1,
			items = {"Comentar Linhas", "Remover Linhas Comentadas"}, value = "Comentar Linhas", hint = "Comentar ou Remover linhas comentadas?"
		},
		{
			class = "label",
			x = 1, y = 3, width = 1, height = 1,
			label = "Seleccione:"
		},
		{
			class = "dropdown", name = "chosen",
			x = 2, y = 3, width = 5, height = 1,
			items = {"Linhas Seleccionadas"}, value = "Linhas Seleccionadas", hint = "Linhas Seleccionadas ou Estilo Específico?"
		}
	}
	for i,w in pairs(styles) do
		table.insert(conf[5].items,"Estilo: " .. w)
	end
	return conf
end

--Adiciona expressões ao campo de texto
function change_tag(subs,index,config)
	local linha = subs[index]
			if config.comment == "Comentar Linhas" then
				local z = string.find(linha.text,"EN: ")
				if not z then
					--linha.text = linha.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})([a-zA-Z ]+)(.+)", " %2%4 {EN: %1%2 { %3 } %4 { %5%6}") --Versão Alternativa (Sem os "Tradução")
					linha.text = linha.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})(.*)", "Tradução %2Tradução%4 Tradução {EN: %1#1%3#2%5}")
					-- Com expressão itálico numa palavra a meio.
					-- "A fifth victim was {\i1}found{\i0} with most of her blood missing..."

					--linha.text = linha.text:gsub("^([^{]+)({[^}]+})([^{]-)$", " %2 {EN: %1#%3") --Versão Alternativa (Sem os "Tradução")
					linha.text = linha.text:gsub("^([^{]+)({[^}]+})([^{]-)$", "Tradução %2Tradução {EN: %1#%3}")
					-- Com expressão a meio.
					--Tohno,{\blur2} let's go.
					
					--linha.text = linha.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})([.?!]+)", " %2%4%5 {EN: %1%2 { %3 } %4{%5}") --Versão Alternativa (Sem os "Tradução")
					linha.text = linha.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})([.?!]+)", "Tradução %2Tradução%4%5 {EN: %1%2 { %3 } %4{%5}")
					-- Com expressão itálico numa palavra a meio.
					--Yeah, {\i1}certainly{\i0}.
					
					--linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})$", "%1%3 {EN: #%2#%4}") --Versão Alternativa (Sem os "Tradução")
					linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})([a-zA-Z .?!]*)$", "%1Tradução%3Tradução {EN: #1%2#2%4}")
					-- Com expressão inicial e final ou inicial e meio
					-- {\blur1.5\i1}"And now, further news on the serial murders."{\i0}
					-- {\fad(1500,0)\be1}Livro Um\N{\fs65}A Hora do Despertar
					
					--linha.text = linha.text:gsub("^({[^}]+})([^{]+)$", "%1 {EN: #%2}") --Versão Alternativa (Sem os "Tradução")
					linha.text = linha.text:gsub("^({[^}]+})([^{]+)$", "%1Tradução {EN: #%2}")
					-- Com expressão inicial
					--{\pos(320,438)}Thanks for the food
					
					local x = string.find(linha.text,"EN: ")
					if not x then
						--linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})$", "%1%3%5 {EN: #%2#%4#%6}") --Versão Alternativa (Sem os "Tradução")
						linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})(.+)({[^}]+})(.*)$", "%1Tradução %3Tradução%5 Tradução {EN: #1%2#2%4#3%6}")
						--3 tags
						--{\i1\blur3}Next time on {\i0}Occult Academy{\i1}:
					end
					local y = string.find(linha.text,"EN: ")
					if not y then
						--linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})$", "%1%3%5 {EN: #%2#%4#%6}") --Versão Alternativa (Sem os "Tradução")
						linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})(.+)({[^}]+})(.+)({[^}]+})(.*)$", "%1Tradução %3Tradução%5 Tradução %7Tradução%8 Tradução {EN: #1%2#2%4#3%6#4%8#5%10}")
						--5 tags
						--{\i1\blur3}Next time on {\i0}Occult Academy{\i1}teste de {\i0}texto{\i1}LOOOL
					end
					
					--linha.text = linha.text:gsub("^([^{]+)$", " {EN: %1}") --Versão Alternativa (Sem os "Tradução")
					linha.text = linha.text:gsub("^([^{]+)$", "Tradução {EN: %1}")
					-- Sem expressões
					--Okay, senpai, it's a promise then.
				end
			else		
				linha.text = linha.text:gsub(" ?{EN: .+}", "")
				--Remove tudo criado
			end
	subs[index] = linha
end

--Correr pelas linhas escolhidas
function add_tags(subs,sel,config)
	if config.chosen == "Linhas Seleccionadas" then
		for x, i in ipairs(sel) do
			change_tag(subs,i,config)
		end
	else
		for i=1, #subs do
			if subs[i].style == config.chosen:sub(9) then
				change_tag(subs,i,config)
			end
		end
	end
end

--Inicialização + GUI
function load_macro_add(subs,sel)
	local config
		ok, config = aegisub.dialog.display(create_confi(subs),{"Adicionar","Cancelar"})
	if ok == "Adicionar" then
		cleantags_subs(subs)
		add_tags(subs,sel,config)
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

--Registar macro no aegisub
aegisub.register_macro(script_name,script_description,load_macro_add)
