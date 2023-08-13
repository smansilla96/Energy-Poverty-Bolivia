****** ALGORITMOS PREDICCION ENERGY POVERTY
cd "C:\Sergio\Documentos\Artículos y Documentos\BCB 14\DTEnergyPoverty\Do files"
use EH2005-2019_energy, clear

tab g_elec gestion if g_elec==., m
tab g_coc gestion if g_coc==., m

replace g_elec=0 if inlist(g_elec,99999,888888,999999,.)
replace g_coc=0 if inlist(g_coc,888888,999999,.)

tab g_elec, m
tab g_coc, m

cap drop g_energy
gen g_energy=g_elec+g_coc
label var g_energy "Gasto mensual en energía"

tab g_energy, m

save "C:\Sergio\Documentos\Artículos y Documentos\BCB 14\DTEnergyPoverty\Do files\EH2005-2019_energyf.dta", replace

*************************** Creación de variables de acuerdo a la literatura
use EH2005-2019_energyf, clear
sort gestion folio 
br 

keep if yhog>0 & yhog!=.
table gestion

tab gestion area, m
tab gestion area if gestion!=2008 & gestion!=2009, m
table gestion area if gestion!=2008 & gestion!=2009, m

//-----------------------------------Dimension de gasto en energía e ingresos del hogar 
tab g_energy, m

// gasto en energía como proporción de los ingresos del hogar
cap drop pgernergy
gen pgernergy=g_energy/yhog
label var pgernergy "Gasto en energía en porcentaje de los ingresos totales del hogar"

cap label drop d1_energy 
label define d1_energy 0 "No Deprivado" 1 "Deprivado"

// Pobreza energética oculta (la mitad de la mediana) (Tirado et al, 2018)
cap drop medpgen
bys gestion: egen medpgen=median(pgernergy) 
label var medpgen "Mediana Nacional"
tab gestion medpgen

codebook area
table area gestion, c(median pgernergy)

cap drop medpgenurb
bys gestion: egen medpgenurb=median(pgernergy) if area==1
label var medpgenurb "Mediana Urbana"
tab gestion medpgenurb
tab area if area==1

cap drop medpgenrur
bys gestion: egen medpgenrur=median(pgernergy) if area==0
label var medpgenrur "Mediana Rural"
tab gestion medpgenrur
tab area if area==0

cap drop medpgen3
gen medpgen3=medpgen/2
label var medpgen3 "Mitad de la mediana nacional"
tab gestion medpgen3

cap drop medpgen3urb
gen medpgen3urb=medpgenurb/2 if area==1
label var medpgen3urb "Mitad de la mediana urbana"
tab gestion medpgen3urb

cap drop medpgen3rur
gen medpgen3rur=medpgenrur/2 if area==0
label var medpgen3rur "Mitad de la mediana rural"
tab gestion medpgen3rur

cap drop d3_energy
gen d3_energy=0
replace d3_energy=1 if pgernergy<=medpgen3
replace d3_energy=. if pgernergy==.
label var d3_energy "Pobreza energética oculta (mitad de la mediana nacional o menos)"
label values d3_energy d1_energy 
tab gestion d3_energy, r
tab d3_energy

cap drop d3_energyarea
gen d3_energyarea=0
replace d3_energyarea=1 if (pgernergy<=medpgen3urb & area==1) | (pgernergy<=medpgen3rur & area==0)
replace d3_energyarea=. if pgernergy==.
label var d3_energyarea "Pobreza energética oculta (mitad de la mediana por área o menos)"
label values d3_energyarea d1_energy 
bys gestion: tab area d3_energyarea, r
tab d3_energyarea

table d3_energy gestion, m
table d3_energyarea gestion, m

table gestion, m c(mean d3_energy)
table gestion area, m c(mean d3_energyarea)

tab d3_energy // prueba de construcción de variables. No se puede estar deprivado en ambos

//-----------------------------------Dimension de acceso a energía de iluminación

// No acceso a electricidad
cap drop noelec
gen noelec=0
replace noelec=1 if electricidad==0
replace noelec=. if electricidad==.
label var noelec "No tiene acceso a electricidad"
label val noelec d1_energy
tab noelec elec
tab noelec

table noelec gestion, m
	tab noelec gestion if area==1, m col // urbano 
	tab noelec gestion if area==0, m col // rural 

table gestion area, m c(mean noelec)

//-----------------------------------Dimension de Combustible y contaminación de interiores

// Uso de combustible de biomasa para cocinar
codebook comb_coc

cap drop biocombus
gen biocombus=0
replace biocombus=1 if comb_coc==1
replace biocombus=. if comb_coc==.
label var biocombus "Uso de combustible de biomasa para cocinar"
label val biocombus d1_energy
tab biocombus comb_coc
tab biocombus

table biocombus gestion, missing
tab biocombus gestion, m
	tab biocombus gestion if area==1, col // urbano 
	tab biocombus gestion if area==0, col // rural 

table gestion area, m c(mean biocombus)

// No tiene un cuarto solamente para cocinar
cap drop nococina
gen nococina=0
replace nococina=1 if cocina==0
replace nococina=. if cocina==.
label var nococina "No tiene un cuarto solamente para cocinar"
label val nococina d1_energy
tab nococina cocina, m
tab nococina
	tab nococina gestion if area==1, col // urbano 
	tab nococina gestion if area==0, col // rural 
table nococina gestion

table gestion area, m c(mean nococina)


//-----------------------------------Dimension Equipamiento para fines alimenticios
// No Tenencia de refrigerador (almacenamiento de alimentos)
cap drop norefri
gen norefri=0
replace norefri=1 if eq_refri==0
replace norefri=. if eq_refri==.
label var norefri "No tiene refrigerador"
label val norefri d1_energy
tab norefri eq_refri, m
tab norefri
	tab norefri gestion if area==1, col // urbano 
	tab norefri gestion if area==0, col // rural 

table norefri gestion
table gestion area, m c(mean norefri)

//No tiene cocina o microondas
cap drop nococmic
gen nococmic=0
replace nococmic=1 if eq_coc==0
replace nococmic=. if eq_coc==.
label var nococmic "No tiene cocina o microondas"
label val nococmic d1_energy
tab nococmic eq_coc, m
tab nococmic
	tab nococmic gestion if area==1, col // urbano 
	tab nococmic gestion if area==0, col // rural 

table nococmic gestion
table gestion, c(mean nococmic)
table gestion area, m c(mean nococmic)

//-----------------------------------Dimension de tenencia de bienes

//No tenencia de computadora
cap drop nocompu
gen nocompu=0
replace nocompu=1 if eq_cpu==0
replace nocompu=. if eq_cpu==. 
label var nocompu "No tiene computadora"
label val nocompu d1_energy
tab nocompu eq_cpu, m
tab nocompu
	tab nocompu gestion if area==1, col // urbano 
	tab nocompu gestion if area==0, col // rural 

table nocompu gestion 
table area gestion , c(mean nocompu)
table gestion area, m c(mean nocompu)

//No tenencia de radio
cap drop norad
gen norad=0
replace norad=1 if eq_rad==0
replace norad=. if eq_rad==. 
label var norad "No tiene radio"
label val norad d1_energy
tab norad eq_rad, m
tab norad
	tab norad gestion if area==1, col // urbano 
	tab norad gestion if area==0, col // rural 

table norad gestion
table area gestion , c(mean norad)
table gestion area, m c(mean norad)

//No tenencia de tv
cap drop notv
gen notv=0
replace notv=1 if eq_tv==0
replace notv=. if eq_tv==. 
label var notv "No tiene tv"
label val notv d1_energy
tab notv eq_tv, m
tab notv
	tab notv gestion if area==1, col // urbano 
	tab notv gestion if area==0, col // rural 

table notv gestion
table area gestion , c(mean notv)
table gestion area, m c(mean notv)


// Acceso a internet
cap drop nointer 
gen nointer=0
replace nointer=1 if internet==0
replace nointer=. if internet==.
label var nointer "No tiene internet"
label val nointer d1_energy
tab nointer, m
	tab nointer gestion if area==1, col // urbano 
	tab nointer gestion if area==0, col // rural 

table nointer gestion
table area gestion , c(mean nointer)
table gestion area, m c(mean nointer)


/////////////////////////////////////////////////////////////////////////////// Dimensiones con pesos iguales: 
*1. Gasto en energía											0.2
	*Pobreza energética oculta 						0.2
	// Se hace para área urbana y rural con el mismo peso
	codebook d3_energyarea
	cap drop wd1_1
	gen wd1_1=d3_energyarea*0.2
	tab gestion wd1_1, m
br gestion folio d3_energyarea wd1_1

*2. Acceso a energía de iluminación, electricidad 			0.2
	*Acceso a electricidad							0.2
	// Se hace para área urbana y rural con el mismo peso
	codebook noelec
	cap drop wd2_1
	gen wd2_1=noelec*0.2	
	tab gestion wd2_1, m
br gestion folio noelec wd2_1

*3. Combustible y contaminación de interiores				0.2
	*Uso de biomasa para cocinar 					0.1
	// Se hace para área urbana y rural con el mismo peso
	codebook biocombus
	cap drop wd3_1
	gen wd3_1=biocombus*0.1
	tab gestion wd3_1, m
br gestion folio biocombus wd3_1
	
	*Cuarto solo para cocinar						0.1
	// Se hace para área urbana y rural con el mismo peso
	codebook nococina
	cap drop wd3_2
	gen wd3_2=nococina*0.1
	tab gestion wd3_2, m
br gestion folio nococina wd3_2
	
*4. Equipamiento para fines alimenticios						0.2
	*Tenencia de refrigerador 						0.1
	// Se hace para área urbana y rural con el mismo peso
	codebook nococina
	cap drop wd4_1
	gen wd4_1=norefri*0.1
	tab gestion wd4_1, m
br gestion folio norefri wd4_1

	*Tenencia de cocina, horno o microondas			0.1
	// Se hace para área urbana y rural con el mismo peso
	codebook nococmic
	cap drop wd4_2
	gen wd4_2=nococmic*0.1
	tab gestion wd4_2, m
br gestion folio nococmic wd4_2

*5. Educación y Comunicación 								0.2
	/* ********************Versión 1: Se hace para área urbana y rural con el mismo peso para todas las variables*/
	*Acceso a internet 
	codebook nointer
	cap drop wd5_1_v1
	gen wd5_1_v1=nointer*0.05
	tab gestion wd5_1_v1, m
br gestion folio nointer wd5_1_v1

	*Tenencia de Computadora	
	// Se hace para área urbana y rural con el mismo peso
	codebook nocompu
	cap drop wd5_2_v1
	gen wd5_2_v1=nocompu*0.05
	tab gestion wd5_2_v1, m
br gestion folio nocompu wd5_2_v1

	*Tenencia de TV									
	// Se hace para área urbana y rural con el mismo peso
	codebook notv
	cap drop wd5_3_v1
	gen wd5_3_v1=notv*0.05
	tab gestion wd5_3_v1, m
br gestion folio notv wd5_3_v1

	*Tenencia de radio
	// Se hace para área urbana y rural con el mismo peso
	codebook norad
	cap drop wd5_4_v1
	gen wd5_4_v1=norad*0.05
	tab gestion wd5_4_v1, m
br gestion folio norad wd5_4_v1

	/* *****************Versión 2: Las variables y sus pesos varían por área, solo se deja fijo el acceso a internet con peso de 0.1*/
	*Acceso a internet 
	codebook nointer
	cap drop wd5_1_v2
	gen wd5_1_v2=nointer*0.1 // para urbanos y rurales
	tab gestion wd5_1_v2, m
br gestion folio area nointer wd5_1_v2

	*Tenencia de Computadora	
	// Se hace para área urbana y rural con el mismo peso
	codebook nocompu
	cap drop wd5_2_v2
	gen wd5_2_v2=nocompu*0.05 if area==1 //solo para urbanos
	tab gestion wd5_2_v2, m
	tab gestion area, m
br gestion folio area nocompu wd5_2_v2

	*Tenencia de TV									
	// Se hace para área urbana y rural con el mismo peso
	codebook notv
	cap drop wd5_3_v2
	gen wd5_3_v2=notv*0.05 // para urbanos y rurales
	tab gestion wd5_3_v2, m
br gestion folio area notv wd5_3_v2

	*Tenencia de radio
	// Se hace para área urbana y rural con el mismo peso
	codebook norad
	cap drop wd5_4_v2
	gen wd5_4_v2=norad*0.05 if area==0 //solo para rurales
	tab gestion wd5_4_v2, m
	tab gestion area, m
br gestion folio area norad wd5_4_v2


//////////////////////////////////// Suma de pesos de variables:

tab gestion d3_energyarea, m
tab gestion noelec, m
tab gestion biocombus, m 
tab gestion nococina, m
tab gestion norefri, m
tab gestion nococmic, m
tab gestion nocompu, m
tab gestion norad, m
tab gestion notv, m
tab gestion nointer, m

cap drop auxm
gen auxm=0 
replace auxm=1 if d3_energyarea==.| noelec==. | biocombus==.| nococina==.| norefri==.| nococmic==.| nocompu==.| norad==.| notv==.| nointer==.
tab gestion auxm, m

/////////////////////// MEPI
cap drop mepicount2
gen mepicount2=wd1_1 + wd2_1 + wd3_1 + wd3_2 + wd4_1 + wd4_2 + wd5_1_v2 + wd5_2_v2 + wd5_3_v2 if auxm==0 & area==1 // para urbanos
replace mepicount2=wd1_1 + wd2_1 + wd3_1 + wd3_2 + wd4_1 + wd4_2 + wd5_1_v2 + wd5_3_v2 + wd5_4_v2 if auxm==0 & area==0 // para rurales
bys gestion: tab mepicount2 area if auxm==0, m
tab mepicount2 if auxm==0 , m


///////// k=1: Peso>=0.2
*Incidencia
cap drop epob2_inck1
gen epob2_inck1=0
replace epob2_inck1=1 if mepicount2>=0.2
cap label drop enerpob
label define enerpob 0 "No Pobre" 1 "Pobre"
label values epob2_inck1 enerpob
bys gestion: tab area epob2_inck1, m r

table gestion epob2_inck1 area 				// Conteo
table gestion area, c(mean epob2_inck1)		// Tasa de incidencia

*Intensidad (promedio de ponderación entre los pobres)
mean mepicount2 if epob2_inck1==1, over(gestion area)
table gestion area if epob2_inck1==1, c(mean mepicount2)	// Tasa de intensidad

*deprivaciones más frecuentes (en 2 tablas, en el mismo orden que tablas de paper)
table area gestion if epob2_inck1==1, c(mean d3_energyarea mean noelec mean biocombus mean nococina mean norefri)
table area gestion if epob2_inck1==1, c(mean nococmic mean nointer mean nocompu mean notv mean norad)

///////// k=2: Peso>=0.4
*Incidencia
cap drop epob2_inck2
gen epob2_inck2=0
replace epob2_inck2=1 if mepicount2>=0.4
label values epob2_inck2 enerpob
bys gestion: tab area epob2_inck2, m r

table gestion epob2_inck2 area 				// Conteo
table gestion area, c(mean epob2_inck2)		// Tasa de incidencia

*Intensidad
mean mepicount2 if epob2_inck2==1, over(gestion area)
table gestion area if epob2_inck2==1, c(mean mepicount2)	// Tasa de intensidad

*deprivaciones más frecuentes
table area gestion if epob2_inck2==1, c(mean d3_energyarea mean noelec mean biocombus mean nococina mean norefri)
table area gestion if epob2_inck2==1, c(mean nococmic mean nointer mean nocompu mean notv mean norad)

///////// k=3: Peso>=0.6
*Incidencia
cap drop epob2_inck3
gen epob2_inck3=0
replace epob2_inck3=1 if mepicount2>=0.6
label values epob2_inck3 enerpob
bys gestion: tab area epob2_inck3, m r

table gestion epob2_inck3 area 				// Conteo
table gestion area, c(mean epob2_inck3)		// Tasa de incidencia

*Intensidad
mean mepicount2 if epob2_inck3==1, over(gestion area)
table gestion area if epob2_inck3==1, c(mean mepicount2)	// Tasa de intensidad

table gestion area if epob2_inck3==1, c(mean d3_energyarea)
table gestion area if epob2_inck3==1, c(mean noelec)
table gestion area if epob2_inck3==1, c(mean biocombus)
table gestion area if epob2_inck3==1, c(mean nococina)
table gestion area if epob2_inck3==1, c(mean norefri)
table gestion area if epob2_inck3==1, c(mean nococmic)
table gestion area if epob2_inck3==1, c(mean nointer)
table gestion area if epob2_inck3==1, c(mean nocompu)
table gestion area if epob2_inck3==1, c(mean notv)
table gestion area if epob2_inck3==1, c(mean norad)

///////// k=4: Peso>=0.8
*Incidencia
cap drop epob2_inck4
gen epob2_inck4=0
replace epob2_inck4=1 if mepicount2>=0.8
label values epob2_inck4 enerpob
bys gestion: tab area epob2_inck4, m r

table gestion epob2_inck4 area 				// Conteo
table gestion area, c(mean epob2_inck4)		// Tasa de incidencia

*Intensidad
mean mepicount2 if epob2_inck4==1, over(gestion area)
table gestion area if epob2_inck4==1, c(mean mepicount2)	// Tasa de intensidad

table gestion area if epob2_inck4==1, c(mean d3_energyarea)
table gestion area if epob2_inck4==1, c(mean noelec)
table gestion area if epob2_inck4==1, c(mean biocombus)
table gestion area if epob2_inck4==1, c(mean nococina)
table gestion area if epob2_inck4==1, c(mean norefri)
table gestion area if epob2_inck4==1, c(mean nococmic)
table gestion area if epob2_inck4==1, c(mean nointer)
table gestion area if epob2_inck4==1, c(mean nocompu)
table gestion area if epob2_inck4==1, c(mean notv)
table gestion area if epob2_inck4==1, c(mean norad)

///////// k=5: Peso==1
*Incidencia
cap drop epob2_inck5
gen epob2_inck5=0
replace epob2_inck5=1 if mepicount2==1
label values epob2_inck5 enerpob
bys gestion: tab area epob2_inck5, m r

table gestion epob2_inck5 area 				// Conteo
table gestion area, c(mean epob2_inck5)		// Tasa de incidencia

*Intensidad
mean mepicount2 if epob2_inck5==1, over(gestion area)
table gestion area if epob2_inck5==1, c(mean mepicount2)	// Tasa de intensidad

table gestion area if epob2_inck5==1, c(mean d3_energyarea)
table gestion area if epob2_inck5==1, c(mean noelec)
table gestion area if epob2_inck5==1, c(mean biocombus)
table gestion area if epob2_inck5==1, c(mean nococina)
table gestion area if epob2_inck5==1, c(mean norefri)
table gestion area if epob2_inck5==1, c(mean nococmic)
table gestion area if epob2_inck5==1, c(mean nointer)
table gestion area if epob2_inck5==1, c(mean nocompu)
table gestion area if epob2_inck5==1, c(mean notv)
table gestion area if epob2_inck5==1, c(mean norad)


save "C:\Sergio\Documentos\Artículos y Documentos\BCB 14\DTEnergyPoverty\Do files\EH2005-2019_energyMLTESTING.dta", replace

/////////////////////////////////////////////////////////////////////////////// Dimensiones con pesos de PCA: 
*1. Gasto en energía											0.05 (Urbano)      0.1 (Rural)
	*Pobreza energética oculta 						0.05 (Urbano)      0.1 (Rural)
	codebook d3_energyarea
	cap drop wd1_1_PCA
	gen wd1_1_PCA=.
	replace wd1_1_PCA=d3_energyarea*0.05 if area==1
	replace wd1_1_PCA=d3_energyarea*0.1 if area==0
	tab gestion wd1_1_PCA, m
br gestion folio area d3_energyarea wd1_1_PCA

*2. Acceso a energía de iluminación, electricidad 			0.05 (Urbano)      0.15 (Rural)
	*Acceso a electricidad							0.05 (Urbano)      0.15 (Rural)
	codebook noelec
	cap drop wd2_1_PCA
	gen wd2_1_PCA=.
	replace wd2_1_PCA=noelec*0.05 if area==1
	replace wd2_1_PCA=noelec*0.15 if area==0
	tab gestion wd2_1_PCA, m
br gestion folio area noelec wd2_1_PCA

*3. Combustible y contaminación de interiores				0.2 (Urbano)      0.2 (Rural)
	*Uso de biomasa para cocinar 					0.1 (Urbano)      0.15 (Rural)
	codebook biocombus
	cap drop wd3_1_PCA
	gen wd3_1_PCA=.
	replace wd3_1_PCA=biocombus*0.1 if area==1
	replace wd3_1_PCA=biocombus*0.15 if area==0
	tab gestion wd3_1_PCA, m
br gestion folio area biocombus wd3_1_PCA
	
	*Cuarto solo para cocinar						0.1 (Urbano)      0.05 (Rural)
	codebook nococina
	cap drop wd3_2_PCA
	gen wd3_2_PCA=.
	replace wd3_2_PCA=nococina*0.1 if area==1
	replace wd3_2_PCA=nococina*0.05 if area==0
	tab gestion wd3_2, m
br gestion folio area nococina wd3_2_PCA
	
*4. Equipamiento para fines alimenticios						0.25 (Urbano)      0.25 (Rural)
	*Tenencia de refrigerador 						0.15 (Urbano)      0.1 (Rural)
	codebook norefri
	cap drop wd4_1_PCA
	gen wd4_1_PCA=.
	replace wd4_1_PCA=norefri*0.15 if area==1
	replace wd4_1_PCA=norefri*0.1 if area==0
	tab gestion wd4_1_PCA, m
br gestion folio area norefri wd4_1_PCA

	*Tenencia de cocina, horno o microondas			0.1 (Urbano)      0.15 (Rural)
	codebook nococmic
	cap drop wd4_2_PCA
	gen wd4_2_PCA=.
	replace wd4_2_PCA=nococmic*0.1 if area==1
	replace wd4_2_PCA=nococmic*0.15 if area==0
	tab gestion wd4_2_PCA, m
br gestion folio area nococmic wd4_2_PCA

*5. Educación y Comunicación 								0.45 (Urbano)      0.3 (Rural)

	*Acceso a internet                              0.15 (Urbano)      0.05 (Rural)
	codebook nointer
	cap drop wd5_1_PCA
	gen wd5_1_PCA=.
	replace wd5_1_PCA=nointer*0.15 if area==1
	replace wd5_1_PCA=nointer*0.05 if area==0
	tab gestion wd5_1_PCA, m
br gestion folio area nointer wd5_1_PCA

	*Tenencia de Computadora                         0.15 (Urbano)      0.05 (Rural)	
	codebook nocompu
	cap drop wd5_2_PCA
	gen wd5_2_PCA=.
	replace wd5_2_PCA=nocompu*0.15 if area==1
	replace wd5_2_PCA=nocompu*0.05 if area==0
	tab gestion wd5_2_PCA, m
br gestion folio area nocompu wd5_2_PCA

	*Tenencia de TV	                              0.10 (Urbano)      0.15 (Rural)				
	codebook notv
	cap drop wd5_3_PCA
	gen wd5_3_PCA=.
	replace wd5_3_PCA=notv*0.10 if area==1
	replace wd5_3_PCA=notv*0.15 if area==0
	tab gestion wd5_3_PCA, m
br gestion folio area notv wd5_3_PCA

	*Tenencia de radio                            0.05 (Urbano)      0.05 (Rural)
	codebook norad
	cap drop wd5_4_PCA
	gen wd5_4_PCA=.
	replace wd5_4_PCA=norad*0.05 if area==1
	replace wd5_4_PCA=norad*0.05 if area==0
	tab gestion wd5_4_PCA, m
br gestion folio area norad wd5_4_PCA



//////////////////////////////////// Suma de pesos de variables:
cap drop mepicountPCA
gen mepicountPCA=wd1_1_PCA + wd2_1_PCA + wd3_1_PCA + wd3_2_PCA + wd4_1_PCA + wd4_2_PCA + wd5_1_PCA + wd5_2_PCA + wd5_3_PCA + wd5_4_PCA 
bys gestion: tab mepicountPCA area, m
br gestion folio d3_energyarea wd1_1_PCA noelec wd2_1_PCA biocombus wd3_1_PCA nococina wd3_2_PCA norefri wd4_1_PCA nococmic wd4_2_PCA nointer wd5_1_PCA nocompu wd5_2_PCA notv wd5_3_PCA norad wd5_4_PCA


///////// k=1: Peso>=0.2
*Incidencia
cap drop epob2_inck1_PCA
gen epob2_inck1_PCA=0
replace epob2_inck1_PCA=1 if mepicountPCA>=0.2
cap label drop enerpob
label define enerpob 0 "No Pobre" 1 "Pobre"
label values epob2_inck1_PCA enerpob
bys gestion: tab area epob2_inck1_PCA, m r

table gestion epob2_inck1_PCA area 				// Conteo
table gestion area, c(mean epob2_inck1_PCA)		// Tasa de incidencia

*Intensidad (promedio de ponderación entre los pobres)
mean mepicountPCA if epob2_inck1_PCA==1, over(gestion area)
table gestion area if epob2_inck1_PCA==1, c(mean mepicountPCA)	// Tasa de intensidad

*deprivaciones más frecuentes (en 2 tablas, en el mismo orden que tablas de paper)
table area gestion if epob2_inck1_PCA==1, c(mean d3_energyarea mean noelec mean biocombus mean nococina mean norefri)
table area gestion if epob2_inck1_PCA==1, c(mean nococmic mean nointer mean nocompu mean notv mean norad)

///////// k=2: Peso>=0.4
*Incidencia
cap drop epob2_inck2_PCA
gen epob2_inck2_PCA=0
replace epob2_inck2_PCA=1 if mepicountPCA>=0.4
label values epob2_inck2_PCA enerpob
bys gestion: tab area epob2_inck2_PCA, m r

table gestion epob2_inck2_PCA area 				// Conteo
table gestion area, c(mean epob2_inck2_PCA)		// Tasa de incidencia

*Intensidad
mean mepicountPCA if epob2_inck2_PCA==1, over(gestion area)
table gestion area if epob2_inck2_PCA==1, c(mean mepicountPCA)	// Tasa de intensidad

*deprivaciones más frecuentes
table area gestion if epob2_inck2_PCA==1, c(mean d3_energyarea mean noelec mean biocombus mean nococina mean norefri)
table area gestion if epob2_inck2_PCA==1, c(mean nococmic mean nointer mean nocompu mean notv mean norad)

///////// k=3: Peso>=0.6
*Incidencia
cap drop epob2_inck3_PCA
gen epob2_inck3_PCA=0
replace epob2_inck3_PCA=1 if mepicountPCA>=0.6
label values epob2_inck3_PCA enerpob
bys gestion: tab area epob2_inck3_PCA, m r

table gestion epob2_inck3_PCA area 				// Conteo
table gestion area, c(mean epob2_inck3_PCA)		// Tasa de incidencia

*Intensidad
mean mepicountPCA if epob2_inck3_PCA==1, over(gestion area)
table gestion area if epob2_inck3_PCA==1, c(mean mepicountPCA)	// Tasa de intensidad

table gestion area if epob2_inck3_PCA==1, c(mean d3_energyarea)
table gestion area if epob2_inck3_PCA==1, c(mean noelec)
table gestion area if epob2_inck3_PCA==1, c(mean biocombus)
table gestion area if epob2_inck3_PCA==1, c(mean nococina)
table gestion area if epob2_inck3_PCA==1, c(mean norefri)
table gestion area if epob2_inck3_PCA==1, c(mean nococmic)
table gestion area if epob2_inck3_PCA==1, c(mean nointer)
table gestion area if epob2_inck3_PCA==1, c(mean nocompu)
table gestion area if epob2_inck3_PCA==1, c(mean notv)
table gestion area if epob2_inck3_PCA==1, c(mean norad)

///////// k=4: Peso>=0.8
*Incidencia
cap drop epob2_inck4_PCA
gen epob2_inck4_PCA=0
replace epob2_inck4_PCA=1 if mepicountPCA>=0.8
label values epob2_inck4_PCA enerpob
bys gestion: tab area epob2_inck4_PCA, m r

table gestion epob2_inck4_PCA area 				// Conteo
table gestion area, c(mean epob2_inck4_PCA)		// Tasa de incidencia

*Intensidad
mean mepicountPCA if epob2_inck4_PCA==1, over(gestion area)
table gestion area if epob2_inck4_PCA==1, c(mean mepicountPCA)	// Tasa de intensidad

table gestion area if epob2_inck4==1, c(mean d3_energyarea)
table gestion area if epob2_inck4==1, c(mean noelec)
table gestion area if epob2_inck4==1, c(mean biocombus)
table gestion area if epob2_inck4==1, c(mean nococina)
table gestion area if epob2_inck4==1, c(mean norefri)
table gestion area if epob2_inck4==1, c(mean nococmic)
table gestion area if epob2_inck4==1, c(mean nointer)
table gestion area if epob2_inck4==1, c(mean nocompu)
table gestion area if epob2_inck4==1, c(mean notv)
table gestion area if epob2_inck4==1, c(mean norad)

///////// k=5: Peso==1
*Incidencia
cap drop epob2_inck5_PCA
gen epob2_inck5_PCA=0
replace epob2_inck5_PCA=1 if mepicountPCA==1
label values epob2_inck5_PCA enerpob
bys gestion: tab area epob2_inck5_PCA, m r

table gestion epob2_inck5_PCA area 				// Conteo
table gestion area, c(mean epob2_inck5_PCA)		// Tasa de incidencia

*Intensidad
mean mepicountPCA if epob2_inck5_PCA==1, over(gestion area)
table gestion area if epob2_inck5_PCA==1, c(mean mepicountPCA)	// Tasa de intensidad

table gestion area if epob2_inck5==1, c(mean d3_energyarea)
table gestion area if epob2_inck5==1, c(mean noelec)
table gestion area if epob2_inck5==1, c(mean biocombus)
table gestion area if epob2_inck5==1, c(mean nococina)
table gestion area if epob2_inck5==1, c(mean norefri)
table gestion area if epob2_inck5==1, c(mean nococmic)
table gestion area if epob2_inck5==1, c(mean nointer)
table gestion area if epob2_inck5==1, c(mean nocompu)
table gestion area if epob2_inck5==1, c(mean notv)
table gestion area if epob2_inck5==1, c(mean norad)
