# yes the dreaded Utils Library :P with much love written for oncle Bob
# 

function unEquate(str)
    str = replace(str, "\\begin{equation}" => "")
    str = replace(str, "\\end{equation}" => "")
    str = replace(str, "\$" => "")
    str = replace(str, "\n" => "")
return str
end




