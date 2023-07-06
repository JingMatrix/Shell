# fix unicode problem output from pdftotext
s/é/é/g
s/ﬁ/fi/g
s/ő/ö/g
s/ö/ö/g
s/ﬀ/ff/g
s/ü/ü/g
s/ř/ř/g
s/ı́/í/g
s/Š/Š/g
s/ﬂ/fi/g
s/á/á/g
s/ﬃ/ffi/g
s/ó/ó/g
s/’/'/g
s/ń/ń/g
s/incar\w/incaré/
# remove possible control character
s/[]//g
# useless preposition at the beginning
s/^by //g
s/^on //g
s/^in //g
s/^for //g
s/^of //g
s/^a //g
# for better display
s/\s*\bI*Rn\b\s*/ℝⁿ/g
s/\s*\bI*Rd\b\s*/ℝᵈ/g
s/\s*\bI*R\b\s*/ℝ/g
s/\s*\bI*IE\b\s*/𝔼/g
s/\s*\bLp\b\s*/ Lₚ /g
s/\s*\bL1\b\s*/ L₁ /g
s/\s*\bL0\b\s*/ L₀ /g
# remove page numbers
s/\s+[0-9]+\s*$//g
s/[0-9]+,\s*[0-9]+\s*//g
s/,.*//g
# remove rebundant space
s/\s*-\s*/-/g
s/\s$//g
# remove invalid lines
/\b[0-9]+\b$/d
/Index/d
/^.{0,5}$/d
/:/d
/^\W/d
/II/d
/\([^\)]*$/d
# word convention
s/semi-?/semi-/g
# parenthess
s/\(([a-zA-Z']+)\)/\1/g
s/^([^\(]+)\)$/\1/
# vim keywords
/[∗.]/d
s/ /\n/g
