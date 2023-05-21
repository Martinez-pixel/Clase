### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3bfa6005-f13a-44cd-907f-4ae3ed7420b4
using PlutoUI, Plots, LaTeXStrings

# ╔═╡ c4684f28-c95b-4478-bde8-dbc19852a166
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""

# ╔═╡ 610ac7dc-84f0-11ec-0293-d5aea54961f4
md"# Solución numérica de ecuaciones diferenciales ordinarias (Método de Euler)

## Ecuaciones diferenciales ordinarias

Una _ecuación diferencial ordinaria_ (EDO) es una ecuación de la forma

$$f(t,x(t),x'(t),x''(t),...,x^{(n)}(t)) = 0, \quad (\ast)$$

donde $f$ es una función arbitraria, $t$ es una _variable independiente_, $x$ es una función de $t$ llamada _función incógnita_ y $x',x'',...,x^{(n)}$ son derivadas de la función incógnita $x$ con respecto a la variable independiente $t$. Una EDO _de grado_ $n$ es aquella en donde la derivada de la función incógnita de mayor grado que aparece es de grado $n$.

Observemos que, si consideramos que $t$ es la función identidad y $0$ es la función constante cero, entonces una EDO es una igualdad entre funciones; por esto es que la incógnita de una EDO es, precisamente, una **función**.

En otras palabras, una EDO es una igualdad que relaciona a una función de una variable independiente con sus derivadas con respecto a esa variable y con la variable misma. Por ello es que son ampliamente utilizadas para modelar problemas en ciencia e ingeniería que involucran el cambio de alguna variable con respecto a otra _de forma contínua_.

En este curso, nos enfocaremos en ecuaciones diferenciales donde la función incógnita es una función real de variable real. En este caso, una función $x(t)$ es una _solución_ a la ecuación diferencial $(*)$ _en un intervalo_ $I\subseteq\mathbb{R}$ si tanto $x(t)$ como sus derivadas cumplen la ecuación $(\ast)$ para todo $t\in I$.
"

# ╔═╡ c1d72411-519c-4c4a-9fe5-5f9929d1e586
md""" 

**Ejemplo** Consideremos la siguiente EDO de primer grado (o de grado 1)

$$x' - x = 0. \quad (1)$$

Despejando y reescribiendo en notación de Leibniz, tenemos que

$$\frac{d}{dt}x = x.$$

¿Qué función de real de variable real conocemos que es igual a su propia derivada?  La función exponencial:

$$x(t) = e^t.$$

¿Para qué valores reales de $t$ tenemos que $x$ y $x'$ cumplen la ec. $(1)$? Para todo $t\in\mathbb{R}$, como se ve en cualquier curso de cálculo diferencial. Por ende, $x(t) = e^t$ es **una** solución a la EDO $(1)$ en el intervalo $I=\mathbb{R}$. Sin embargo, dado que la derivada de una constante es cero entonces, por la regla de Leibniz, tenemos que

$$\begin{align*} \frac{d}{dt} (Ce^t) &= \bigg(\frac{d}{dt}C\bigg)e^t + C\bigg(\frac{d}{dt}e^t\bigg) \\ &= 0e^t + Ce^t \\ &= Ce^t \end{align*}$$

para todo $C\in\mathbb{R}$. Por lo tanto, cada miembro de la _familia de funciones_

$$\{Ce^t \mid C\in\mathbb{R}\}$$

es una solución a la ecuación $(1)$. A esta familia se le conoce como una _solución general_ de la EDO $(1)$.

"""

# ╔═╡ c5083d27-944d-4c3d-8f6b-301202371003
md""" ### Condiciones iniciales

Las EDOs de la forma $(\ast)$ para las cuales existen soluciones suelen tener soluciones _generales_ . Es decir que, en vez de que sólo exista una función que verifica la EDO, existe toda una familia de funciones que la solucionan, parametrizada por uno o más parámetros. En el **Ejemplo** de la sección anterior, el parámetro $C\in\mathbb{R}$ parametriza la familia de soluciones $\{Ce^t \mid C\in\mathbb{R}\}$; esto significa que, para cada valor real que le demos a $C$, obtendremos una solución _particular_ a la EDO:

"""

# ╔═╡ 6c00513b-4db7-4995-9128-3263e19c7c77
deslizador = @bind C Slider(-10:0.1:10, default = 1)
#= Creamos una variable C, con valor asignado por un "slider" interactivo que se mueve en el rango -10:0.1:10.
Además, le asignamos este "slider" a la variable deslizador para poder cambiar el valor de C más adelante. =#

# ╔═╡ 5c5e85dd-8685-46fc-92fe-416ca717e696
C # Mostramos el valor de C.

# ╔═╡ 1418e9a9-2253-4e03-a627-e64b13a3682a
x(t) = C*exp(t) # Definimos una función x(t) = Ce^t con la variable interactiva C (el parámetro de la familia).

# ╔═╡ 63e3150c-18d2-4db6-8208-810a5eb59b8c
begin
    plot(-1:0.1:9, x, ylims = (-1000,1000), label = L"$Ce^t$")  # Graficamos a la función x de -1 a 9, y
	vline!([0,0], color = "grey", style = :dash, label = false) # agregamos una línea punteada vertical y una
	hline!([0,0], color = "grey", style = :dash, label = false) # línea punteada horizontal en el origen.
end

# ╔═╡ 46853ddf-0d40-4f7b-a480-30292668732b
md"""

Para plantear un problema utilizando EDOs cuya solución, de existir, deba ser _única_, debemos agregar **restricciones**. Éstas suelen venir en forma de ecuaciones algebráicas que obliguen a la solución a tener cierto valor al ser evaluada en un punto específico de su dominio (el intervalo $I$ en que la solución es válida).

"""

# ╔═╡ f2e5c611-e5ff-482a-8e2c-7b645f44424a
md""" **Ejemplo**

Consideremos nuevamente la EDO $(1)$. Como hemos visto, la solución general $\{Ce^t \mid C\in\mathbb{R}\}$ es válida en el intervalo $I=\mathbb{R}$. Supongamos que, adicionalmente, queremos que nuestra solución valga $5$ cuando la evaluamos en $0\in I$, lo cual podemos escribir como

$$x(0) = 5. \quad (2)$$

¿Puedes encontrar el valor de $C$ que hace que se cumpla esta condición?

"""

# ╔═╡ 375b90c4-c8e3-4f15-bc70-bb613bc56908
deslizador # Volvemos a mostrar el "slider" interactivo que le asigna un valor a C en el rango -10:0.1:10.

# ╔═╡ 75c7a854-809c-4ba5-9d2b-4b17e9801c1f
C # Mostramos el valor de C.

# ╔═╡ 3c095cfb-5b4b-436f-9c58-79571ae37537
begin
    plot(-1:0.05:1, x, ylims = (-10,10), label = L"$Ce^t$")     # Graficamos a la función x de -1 a 9,
	vline!([0,0], color = "grey", style = :dash, label = false) # agregamos una línea punteada vertical y una
	hline!([0,0], color = "grey", style = :dash, label = false) # línea punteada horizontal en el origen, y
	scatter!([0],[5], label = L"(0,5)")                         # graficamos un punto en la coordenada (0,5).
end

# ╔═╡ 194d5ee5-0c88-4b12-a7b9-fda675709e84
md"""

Veamos cómo resolver este problema de forma matemática. Sustituyendo nuestra solución general,

$$\begin{align*} x(0) = 5 &\implies Ce^0 = 5 \\ &\implies C(1) = 5 \\ &\implies C = 5, \end{align*}$$

por lo que la solución particular sería $x(t) = 5e^t$. Nota que no hay ninguna otra función de la forma $Ce^t$ que valga $5$ en $0$ más que ésta por lo que, al agregar una _restricción_ a nuestra EDO $(1)$, pasamos de una solución general a una solución _particular_.

"""

# ╔═╡ 0aacbcb0-30dd-4241-aac1-7db4ca76200b
md"""

En general, las restricciones son ecuaciones de la forma

$$x(t_0) = C_0, \quad (\ast\ast)$$

donde se asume que $t_0\in I$ y $C_0\in\mathbb{R}$. Dado que, en la mayoría de los casos, las EDOs se utilizan para modelar variables que suponemos que cambian en función del _tiempo_, a las restricciones impuestas se les conoce por convención como _condiciones iniciales_. A una EDO de la forma $(\ast)$ con una condición inicial de la forma $(\ast\ast)$ (o más condiciones similares para sus derivadas $x', x''$, etc.) se le conoce como un _problema de condiciones iniciales_.

"""

# ╔═╡ 7cf646d6-5c4e-430c-9ee2-a389b81ddb0b
md""" ### Soluciones analíticas y numéricas

En el **Ejemplo** de la sección anterior, la solución que obtuvimos a un problema de condiciones iniciales fue una **función continua** que pudimos expresar matemáticamente mediante una regla de correspondencia sencilla. A esto se le conoce como una _solución analítica_.

Desafortunadamente, dado que la ecuación $(*)$ es muy general, la mayoría de las EDOs existentes **no tienen solución analítica** y, por lo tanto, lo mismo sucede con la mayor parte de los problemas de condiciones iniciales existentes. Afortunadamente, existen **métodos numéricos** que nos permiten **aproximar** la solución de casi cualquier EDO mediante una **función discreta**; a esto se le conoce como una _solución numérica_ de una EDO. Uno de los más simples es el **método de Euler**, que sirve para aproximar soluciones a EDOs de primer grado.

"""

# ╔═╡ 0bf8be91-fdec-455f-b419-848451ef686e
md""" ## Método de Euler

Supongamos que tenemos un problema de condiciones iniciales de la forma

$$\begin{align*} x'(t) &= g(t,x(t)), &(3) \\ x(t_0) &= C_0, &(4) \end{align*}$$

que queremos aproximar en algún intervalo $[t_0,t_f]\subset\mathbb{R}$, con $C_0\in\mathbb{R}$. Observemos que una ecuación de la forma $(3)$ se puede obtener fácilmente a partir de una EDO de primer grado $f(t,x(t),x'(t)) = 0$, simplemente despejando a $x'(t)$.

El método de Euler consiste en crear un arreglo uniforme de puntos en el intervalo $[t_0,t_f]$ y aproximar los valores de $x(t)$ en esos puntos. Una forma sencilla de crear un arreglo de este tipo es tomando un número entero positivo $N$ y luego definiendo un _tamaño de paso_

$$h = \frac{t_f-t_0}{N}$$

y los puntos $t_i$ como

$$t_i = t_0 + ih \quad \forall \ i\in\{1,2,\dots,N\}.$$

En particular, notamos que $t_N = t_f$ y que $t_{i+1}-t_i = h$ para todo $i\in\{0,1,\dots,N-1\}$.

"""

# ╔═╡ 858b97dd-c384-49cd-981a-e2a29ffbfb2a
md""" ### Derivación matemática del método de Euler

Para derivar el método de Euler, utilizaremos nuevamente el Teorema de Taylor, por lo que vale la pena recordarlo.

**Recordatorio** Si una función $f$ es derivable en un punto $a$ y $x$ es un valor cercano a $a$, entonces

$$f(x) = \sum_{k=0}^\infty \frac{f^k(a)(x-a)^k}{k!},$$

donde $f^k$ es la $k$-ésima derivada de $f$ y, en particular, $f^0=f$.

"""

# ╔═╡ be8c0efd-ebe3-454d-8c78-ca66bf2eb249
md"""

Como por la ecuación $(4)$ estamos suponiendo que conocemos el valor de $x$ en $t_0$, lo usaremos como punto de partida. Observemos que, por el Teorema de Taylor, tenemos que

$$x(t_1) = x(t_0) + hx'(t_0) + \frac{h^2}{2}x''(t_0) + \dots.$$

Quedándonos sólo con los primeros dos términos, tenemos que

$$x(t_1) \approx x(t_0) + hx'(t_0).$$

Como $x(t)$ satisface la EDO $(3)$, tenemos que

$$x(t_1) \approx x(t_0) + hg(t_0,x(t_0)).$$

Ahora que tenemos un valor aproximado de $x$ en $t_1$, podemos usarlo como punto de partida y, aplicando los mismos argumentos, obtener 

$$x(t_2) \approx x(t_1) + hg(t_1,x(t_1)),$$

donde $x(t_i)$ es el valor _aproximado_ que obtuvimos anteriormente. De esta forma, podemos siempre aproximar el valor de $x(t_{i+1})$ en términos de nuestra aproximación de $x(t_i)$ como

$$x(t_{i+1}) \approx x(t_i) + hg(t_i,x(t_i))$$

para todo $i\in\{0,1,2,\dots,N-1\}$. En particular, por $(4)$, tenemos que $x(t_1) \approx C_0 + hg(t_0,C_0).$

"""

# ╔═╡ 8655c243-679b-46fb-b506-a0b035e902b7
md""" ### Implementación del método de Euler

**Ejercicio** Crea una función `tamañoDePaso` con parámetros `t0`, `tf` y `N`, donde
* `t0` es el tiempo inicial de un problema de condiciones iniciales,
* `tf` es el tiempo final en el que queremos aproximar una solución a dicho problema, y
* `N` es el número de puntos en los que queremos aproximar nuestra solución,

y devuelva el tamaño de paso $h$ correspondiente, imprimiendo un mensaje de error si $N$ **no** es entero positivo.

"""

# ╔═╡ 643043b9-ae20-4071-9367-b282f2654fd7
# Tu código va aquí :)
begin
function tamañoDePaso(t0, tf, N)
	if !isinteger(N) || N <= 0
		error("N no es entero positivo")
	end
	h = (tf - t0) / N
	return h
end
	t0 = 0
	tf = 1
	N = 10000
h = tamañoDePaso(t0, tf, N)
println("Tamaño de paso: ", h)
end

# ╔═╡ c84d2b95-07a4-45f8-8e7e-e372acc89cb8
md" **Ejercicio** Crea una función `arregloUniforme` que tome los mismos tres parámetros del **Ejercicio** anterior y devuelva un arreglo uniforme de números desde `t0` hasta `tf` con el tamaño de paso dado por `tamañoDePaso`. "

# ╔═╡ b0eb99e9-978a-4914-90a9-e05c73115e73
# Tu código (comentado) va aquí :)
begin
function arregloUniforme(t01, tf1, N1)
	h1 = tamañoDePaso(t0, tf, N)
	t1 = range(t01, stop=tf1, step=h1)
	return t1
end
t01 = 0
tf1 = 1
N1 = 100

	t1 = arregloUniforme(t01, tf1, N1)
	println("Arreglo uniforme de tiempos: ", t1)
end

# ╔═╡ fa999314-0038-498a-ac9e-3ce04a9435a3
md""" **Ejercicio** Crea una función `pasoEuler` con parámetros `ti`, `xti`, `g` y `h`, donde

* `ti` es un valor de tiempo,
* `xti` es una aproximación de $x(t_i)$, donde $x$ es la solución al problema de condiciones iniciales $(3-4)$,
* `g` es la función de $x$ y $t$ dada por la ecuación $(3)$, y
* `h` es el tamaño de paso de nuestro arreglo uniforme,

y devuelva una aproximación de $x(t_{i+1})$.

"""

# ╔═╡ ecf4e2e8-821d-4e32-82d8-5eaec50363c3
# Tu código (comentado) va aquí :)
begin
function pasoEuler(ti,xti, g, h2)
	xi = xti + h * g(xti, ti)
	return xi
end
ti = 0
xti = 2
g(x, h) = x
h2 = 10
	xi = pasoEuler(ti, xti, g, h2)
	println("Aproximación de x(ti+1): ", xi)

end

# ╔═╡ 1ec8d06d-160f-49de-a1aa-25c9d17cce64
md""" **Ejercicio** Crea una función `euler` con parámetros `g`, `xt0` y `T`, donde

* `g` es la función de $x$ y $t$ dada por la ecuación $(3)$,
* `xt0` es la condición inicial dada por la ecuación $(4)$, y
* `T` es un arreglo uniforme de "tiempos" de la forma $\{t_0 + ih \mid h\in\mathbb{R}^+, i\in\mathbb{N}, 0\leq i\leq N\}$,

y devuelva un arreglo con `xt0` y los valores aproximados de $x(t_i)$ para $1\leq i\leq N$, calculados mediante el método de Euler.

**Sugerencia**: Utiliza algunas de las funciones definidas anteriormente.

"""

# ╔═╡ 7c8c2188-3173-4202-8ba4-83554831d940
# Tu código (comentado) va aquí :)
begin
function euler(g1, x0, T)
	N = length(T)
	X = similar(T)
	X[1] = xt0

	for i in 1:N-1
		ti = T[i]
		xti = X[i]
		h = T[i+1] - ti
		X[i+1] =  pasoEuler(ti, xti, g1, h)
	end
	return X
end
	g1(x, t) = x
	xt0 = 1
	T = [0, 0.5, 0.5, 0.5]
	X = euler(g1, xt0, T)
	println("Aproximación de x(ti): ", X)
end

# ╔═╡ 1dc4a3c3-6b1c-4024-bfaf-ce72f5533209
md"""

**Ejercicio** En caso de que la función $g$ de la EDO $(3)$ sólo dependa del tiempo, ¿qué operación matemática estaríamos llevando a cabo al aplicar el método de Euler?

_Tu respuesta va aquí._
: 
Cuando la función g de la EDO (3) depende solo del tiempo, con el método de Euler se obtendría una aproxiamción de la EDO mediante la integración númerica y se reduce a a una ecuación diferencial ordinaria de primer orden, es decir:

$$dx/dt = g(t) ....(5)$$

Este método aproxima la solución de la EDO anterior en el intervalo [t0, tf] mediante valores discretos de la variable independiente x. El tamaño de paso 'h' nos ayuda a calcular iterativamente los valores x(ti) a partir del valor incial x(t0) y la función g(t) evaluada en cada punto como sigue:

$$x(ti+1) = x(ti) + h*g(ti)$$

para todo $$i$$ en $$0, 1,..., N-1$$


Verifica que tu implementación del método de Euler sea correcta aplicándola a alguna función `g` sencilla que sólo dependa del tiempo y comparando los resultados obtenidos con la solución analítica; recuerda que debes imponer una condición inicial.

"""

# ╔═╡ d821fc74-b60f-4571-bd82-44b4f7ece230
#= Tu código (comentado) va aquí :)
   También puedes agregar celdas para discutir tus resultados. =#

# ╔═╡ c44f5b44-8899-444a-b5c4-f87e98102013
md""" **Ejercicio** Utiliza tu implementación del método de Euler para solucionar el problema de condiciones iniciales $(1-2)$. Grafica tu resultado junto con la gráfica de la solución analítica encontrada en el **Ejemplo** de la sección "Condiciones iniciales" y haz interactivo el parámetro $N$ para observar cómo cambia la aproximación que da tu solución numérica de la solución analítica en función del número de puntos en el intervalo $[t_0,t_f]$. """

# ╔═╡ 80b45143-b908-4f89-bb6f-1cb500529ea9
# Tu código (comentado) va aquí :)
begin
	function eulermethod(g2, t0, tf, x0, N)
	h4 = (tf  t0) / N
	t4 =range(t0, stop=tf, length=N+1)
	x4 = zeros(Float64, N+1)
	x4[1] = x0
		for i in 1:N
			x4[i+1]= x4[i] + h3 * g3(t[i], x4[i])
		end
		return t, x4
	end
end
function g2(t, x)
return x4
end

# ╔═╡ e0081798-1e7e-47b3-a7d2-1d0f29d59990
md""" ## Nota final

* El **método de Euler** forma parte de una familia de métodos numéricos para aproximar soluciones numéricas de EDOs conocidos como **métodos de Runge-Kutta**, siendo el más sencillo de ellos. Los métodos de Runge-Kutta se abordan a mayor profundidad en los cursos de **Física Computacional**, incluyendo el método más "clásico", conocido como _RK4_.


* Las aproximaciones a soluciones de EDOs obtenida por el método de Euler (u otros métodos numéricos, como los de Runge-Kutta) **no siempre son válidas**; para que lo sean nuestros problemas de condiciones iniciales deben **tener soluciones únicas** (al menos en algún intervalo) y **estar bien planteadas**; es decir, que cambios pequeños en el planteamiento del problema introduzcan cambios pequeños en las soluciones aproximadas. Los resultados que dan condiciones bajo las cuales se asegura que un problema de condiciones iniciales tenga una solución única y esté bien planteado se demuestran en cursos de **Análisis Numérico**.


* En la práctica, quienes hacen modelación y simulación aplicada utilizando ecuaciones diferenciales (ordinarias, parciales, estocásticas, etc.) pero _no_ se dedican al análisis numérico **no van por la vida estudiando muchos métodos a profundidad e implementándolos cada vez que los necesitan**. Por supuesto, es importante que esas personas estudien e implementen _algunos_ métodos numéricos básicos durante su formación pero, por eficiencia, es mejor dejar esa inmensa y complicada tarea a personas con conocimiento muy especializado tanto en las teorías matemáticas que dan soluciones a esos problemas como en el cómputo de alto rendimiento. En el caso de Julia, el paquete [`DifferentialEquations`](https://diffeq.sciml.ai/stable/) contiene una implementación de cientos de métodos numéricos altamente estables y veloces que permiten resolver una inmensa cantidad de problemas rápidamente, e inclusive es posible utilizar este paquete en otros lenguajes de programación como Python y R.

"""

# ╔═╡ 84f733e5-8e7a-4df7-880d-49ca09683257
md"""

## Recursos complementarios

* Capítulo 5 "Initial-Value Problems for Ordinary Differential Equations" de Burden et al, _Numerical Analysis_ (2019) -principalmente la introducción y las secciones 5.1-5.4.
* Birkhoff y Rota, _Ordinary Differential Equations_ (1989), págs. 142-155.
* Video [Intro to solving differential equations in Julia](https://www.youtube.com/watch?v=KPEqYtEd-zY) de una plática dada por el creador del paquete [`DifferentialEquations`](https://diffeq.sciml.ai/stable/) de Julia.

"""

# ╔═╡ fc7efcf9-70ca-4c3d-9822-720c67dcc7f7
md""" ## Créditos
Este _notebook_ de Pluto fue basado parcialmente en el _notebook_ de Jupyter [`13. Ecuaciones diferenciales ordinarias - metodo de Euler.ipynb`](https://github.com/dpsanders/FisicaComputacional2019_3/blob/master/notebooks/13.%20Ecuaciones%20diferenciales%20ordinarias%20-%20metodo%20de%20Euler.ipynb) del repositorio [`FisicaComputacional2019_3`](https://github.com/dpsanders/FisicaComputacional2019_3/) del Dr. David Philip Sanders. 
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "2d9494c436d91b560bd00be00c183cd4f43e3804"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "be6ab11021cd29f0344d5c4357b163af05a48cba"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.21.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "b306df2650947e9eb100ec125ff8c65ca2053d30"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.1.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "efaac003187ccc71ace6c755b197284cd4811bfe"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.4"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4486ff47de4c18cb511a0da420efebb314556316"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.4+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "69182f9a2d6add3736b7a06ab6416aafdeec2196"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.8.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "98dc144f1e0b299d49e8d23e56ad68d3e4f340a5"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.20"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "7fb975217aea8f1bb360cf1dde70bad2530622d2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "5434b0ee344eaf2854de251f326df8720f6a7b55"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.10"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "2e47054ffe7d0a8872e977c0d09eb4b3d162ebde"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.0.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "0b829474fed270a4b0ab07117dce9b9a2fa7581a"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.12"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─c4684f28-c95b-4478-bde8-dbc19852a166
# ╠═3bfa6005-f13a-44cd-907f-4ae3ed7420b4
# ╟─610ac7dc-84f0-11ec-0293-d5aea54961f4
# ╟─c1d72411-519c-4c4a-9fe5-5f9929d1e586
# ╟─c5083d27-944d-4c3d-8f6b-301202371003
# ╠═6c00513b-4db7-4995-9128-3263e19c7c77
# ╠═5c5e85dd-8685-46fc-92fe-416ca717e696
# ╠═1418e9a9-2253-4e03-a627-e64b13a3682a
# ╠═63e3150c-18d2-4db6-8208-810a5eb59b8c
# ╟─46853ddf-0d40-4f7b-a480-30292668732b
# ╟─f2e5c611-e5ff-482a-8e2c-7b645f44424a
# ╠═375b90c4-c8e3-4f15-bc70-bb613bc56908
# ╠═75c7a854-809c-4ba5-9d2b-4b17e9801c1f
# ╠═3c095cfb-5b4b-436f-9c58-79571ae37537
# ╟─194d5ee5-0c88-4b12-a7b9-fda675709e84
# ╟─0aacbcb0-30dd-4241-aac1-7db4ca76200b
# ╟─7cf646d6-5c4e-430c-9ee2-a389b81ddb0b
# ╠═0bf8be91-fdec-455f-b419-848451ef686e
# ╟─858b97dd-c384-49cd-981a-e2a29ffbfb2a
# ╟─be8c0efd-ebe3-454d-8c78-ca66bf2eb249
# ╟─8655c243-679b-46fb-b506-a0b035e902b7
# ╠═643043b9-ae20-4071-9367-b282f2654fd7
# ╟─c84d2b95-07a4-45f8-8e7e-e372acc89cb8
# ╠═b0eb99e9-978a-4914-90a9-e05c73115e73
# ╟─fa999314-0038-498a-ac9e-3ce04a9435a3
# ╠═ecf4e2e8-821d-4e32-82d8-5eaec50363c3
# ╟─1ec8d06d-160f-49de-a1aa-25c9d17cce64
# ╠═7c8c2188-3173-4202-8ba4-83554831d940
# ╟─1dc4a3c3-6b1c-4024-bfaf-ce72f5533209
# ╠═d821fc74-b60f-4571-bd82-44b4f7ece230
# ╟─c44f5b44-8899-444a-b5c4-f87e98102013
# ╠═80b45143-b908-4f89-bb6f-1cb500529ea9
# ╠═e0081798-1e7e-47b3-a7d2-1d0f29d59990
# ╟─84f733e5-8e7a-4df7-880d-49ca09683257
# ╟─fc7efcf9-70ca-4c3d-9822-720c67dcc7f7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
