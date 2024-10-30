using Statistics
using Symbolics
using Unitful
using Test
using Latexify
include("Utils.jl")


struct Data
    v
    σsys
end

struct DataMultiMes
    v::Vector
    σsys
end

struct DataDerived
    v
    σtot
end

v(Data::Union{Data,DataDerived}) = Data.v

function v(Data::DataMultiMes)
    return mean(Data.v)
end


function v(MessDict)
    MessDict2 = Dict()
    for (key, value) ∈ MessDict
        MessDict2[key] = v(value)
    end
    MessDict2
end




function σsys(Data::Data)
    return Data.σsys
end


function σsys(Data::DataMultiMes)
    return Data.σsys
end

"""
    Calculate the statistical error of a measurement. The statistical error of a single measurement is zero.
"""
function σstat(Data::Data)
    return 0 
end

"""
    Calculate the statistical error of a measurement. The statistical error is the standard deviation of the measurements divided by the square root of the number of measurements.
    
"""
function σstat(Data::DataMultiMes)
    return std(Data.v) / sqrt(length(Data.v))
end

"""
    Calculate the total error of a measurement. The total error is the square root of the sum of the systematic and statistical errors squared.
"""
σtot(Data::Union{DataMultiMes}) = sqrt(σsys(Data)^2 + σstat(Data)^2)

σtot(Data::Data) = σsys(Data)

σtot(Data::DataDerived) = Data.σtot

function evalMessDict(MessDict, file)
    evalMessurmentDict=Dict()

    for (key, value) ∈ MessDict
        value = eval(value)

        mes = DataDerived(v(value), σtot(value))

        file.write(latexify(key), " = ", "\n")

        evalMessurmentDict[key] = mes;
    end
end

function propagate_uncertanty(vₛ , eq , MessDict , file)
	#TODO: Add the functionality to handle soving equation to vₛ 
	
    
	#dict = evalMessDict(MessDict, file) 
    

    DT(v) = Differential(v)(eq.lhs)
    DTE(v) = expand_derivatives(Differential(v)(eq.rhs))



    ET₁= string("\\sigma_{",unEquate(Latexify.latexify(vₛ)),"}")
    ET₂="\\sqrt{"
    ET₃="\\sqrt{"
    ET₄=""

    first = true
    for (key, value) ∈ MessDict
        if(!first) ET₂ = string(ET₂, "+") end
        if(first) first=false end

        ET₂ = string(ET₂, "\\sigma_{"  , unEquate(Latexify.latexify((key))) , "}^2")
        ET₂ = ET₂* unEquate(Latexify.latexify(DT(key)))
    end
    ET₂ = ET₂*"}"



    first = true
    for (key, value) ∈ MessDict
        if(!first) ET₃ = string(ET₃, "+") end
        if(first) first=false end
        
        ET₃ = string(ET₃, "\\sigma_{"  , unEquate(Latexify.latexify((key))) , "}^2")
        ET₃ = ET₃* unEquate(Latexify.latexify(DTE(key)^2))

    end
    ET₃ = ET₃ * "}"



    vᵣ = substitute(eq,v(MessDict)).rhs
    
    
    sσᵣ = vᵣ^2 * 0;
    
    
    
    
    for (key, value) ∈ MessDict
        print(substitute(DTE(key),v(MessDict))^2)
        sσᵣ += σtot(value)^2 * substitute(DTE(key),v(MessDict))^2
    end


    σᵣ=sqrt(sσᵣ)

    un=unit(σᵣ)

    
    ET₄ = unEquate(Latexify.latexify(round(un, σᵣ, digits = 2)))


    vᵣ = substitute(eq,v(MessDict)).rhs

    VT₁ = unEquate(Latexify.latexify(eq))

    VT₁ = string(VT₁, "\\myeqsub", unEquate(Latexify.latexify(round(un, vᵣ, digits = 2))))


    write(file, "\$\$\n", VT₁, "\n\$\$\n")

    write(file, "sub: The variables where substituted with their values and the value was calculated.\\newline","\n");

    write(file, "\$\$\n",
        ET₁,"\\myeqerr", ET₂,"\\myeqder\$\$\\newline\n\$\$", ET₃,"\\myeqsub", ET₄,
        "\n\$\$\n");


    write(file, "err: Formula was derived from the general formula for the error propagation \\newline", "\n");
    write(file, "der: The derovitive was calculated using the expand\\_derivatives() function of the Julia Symbolics library.\\newline", "\n");
    write(file, "sub: The variables where substituted with their values and the propagated uncertanty was calculated.\\newline","\n");

    
	return DataDerived(vᵣ, σᵣ)

end


@testset "error Propagation" begin
    d₁ = Data(1.0, 0.1)
    d₂ = Data(2.0, 0.2)
    @test σstat(d₁) == 0
    @test σstat(d₂) == 0
    @test σsys(d₁) == 0.1
    @test σsys(d₂) == 0.2
    @test σtot(d₁) ≈ 0.1
    @test σtot(d₂) ≈ 0.2
end
