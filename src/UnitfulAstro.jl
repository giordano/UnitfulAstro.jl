__precompile__()

module UnitfulAstro

import Unitful
using Unitful: @unit

macro import_from_unitful(args...)
    expr = Expr(:block)
    for arg in args
        use_SI_prefixes, sym = should_we_use_SI_prefixes(arg)
        if use_SI_prefixes
            for prefix in Unitful.si_prefixes
                sym′ = Symbol(prefix, sym)
                push!(expr.args, :(import Unitful.$sym′))
            end
        else
            push!(expr.args, :(import Unitful.$sym))
        end
    end
    expr
end

function should_we_use_SI_prefixes(arg::Expr)
    if arg.head == :(call)
        if arg.args[1] == :(~)
            return true, arg.args[2]
        else
            error("incorrect first argument")
        end
    else
        error("incorrect expression head")
    end
end
should_we_use_SI_prefixes(arg::Symbol) = false, arg

@import_from_unitful ~m ~s ~A ~K ~cd ~g ~mol
@import_from_unitful ~L ~Hz ~N ~Pa ~J ~W ~C ~V ~Ω ~S ~F ~H ~T ~Wb ~lm ~lx ~Bq ~Gy ~Sv ~kat ~eV
@import_from_unitful sr rad ° °C °Ra °F minute hr d wk ~bar atm Torr
@import_from_unitful q c0 c μ0 µ0 ε0 ϵ0 Z0 G gn ge h ħ Φ0 me mn mp μB µB Na R k σ
@import_from_unitful inch ft yd mi ac lb oz dr gr lbf

import UnitfulAngles: arcminute, arcsecond

@unit erg        "erg"      Erg                       (1//10^7)*J               false
@unit dyn        "dyn"      Dyne                      (1//10^5)*N               false
@unit yr         "yr"       JulianYear                365.25*d                  true
@unit AU         "AU"       AstronomicalUnit          149_597_870_700.0*m       false  # cf IAU 2012
@unit ly         "ly"       LightYear                 1*c*yr                    false
@unit pc         "pc"       Parsec                    1*AU/arcsecond            true   # cf IAU 2015
# Note that IAU 2015 defines the small angle approximation as exact in the definition of the parsec.
@unit Jy         "Jy"       Jansky                    1e-23erg*s^-1*cm^-2*Hz^-1 true
# Note that Jy uses a Float64 conversion factor because 10^23 overflows Int64.

# SOLAR CONVERSION CONSTANTS (IAU 2015)
@unit Rsun       "R⊙"       SolarRadius               6.957e8*m                 false
@unit Ssun       "S⊙"       SolarIrradiance           1361.0*W*m^-2             false
@unit Lsun       "L⊙"       SolarLuminosity           3.828e26*W                false
# TODO solar effective temperature
@unit GMsun      "GM⊙"      GSolarMass                1.327_124_4e20*m^3*s^-2   false
@unit Msun       "M⊙"       SolarMass                 1*GMsun/G                 false

# PLANETARY CONVERSION CONSTANTS (IAU 2015)
@unit Rearth_e   "R⊕ₑ"      EarthEquatorialRadius     6.3781e6*m                false
@unit Rearth_p   "R⊕ₚ"      EarthPolarRadius          6.3568e6*m                false
@unit Rjup_e     "Rjupₑ"    JupiterEquatorialRadius   7.1492e7*m                false
@unit Rjup_p     "Rjupₚ"    JupiterPolarRadius        6.6854e7*m                false
@unit GMearth    "GM⊕"      GEarthMass                3.986_004e14*m^3*s^-2     false
@unit GMjup      "GMjup"    GJupiterMass              1.266_865_3e17*m^3*s^-2   false
@unit Mearth     "M⊕"       EarthMass                 1*GMearth/G               false
@unit Mjup       "Mjup"     JupiterMass               1*GMjup/G                 false
@unit Rearth     "R⊕"       EarthRadius               1*Rearth_e                false
@unit Rjup       "Rjup"     JupiterRadius             1*Rjup_e                  false
# Note that IAU 2015 states that when the radius is not specified as polar or equatorial, the
# equatorial radius should be used.

# Solar flux unit
# https://en.wikipedia.org/wiki/Solar_flux_unit
@unit SFU        "SFU"      SolarFluxUnit             10*kJy                    false

# Total electron content unit (used for ionospheric physics and low-frequency radio astronomy)
@unit TECU       "TECU"     TotalElectronContentUnit  1e16*m^-2                 false

const localunits = Unitful.basefactors
function __init__()
    merge!(Unitful.basefactors, localunits)
    Unitful.register(UnitfulAstro)
end

end

