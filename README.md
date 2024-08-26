\section{Declaraciones Iniciales}
\subsection{Librerías y Paquetes:}
\begin{itemize}
    \item \textbf{IEEE.STD\_LOGIC\_1164:} Define tipos de datos estándar como \texttt{STD\_LOGIC} y \texttt{STD\_LOGIC\_VECTOR}, utilizados para manejar señales digitales.
    \item \textbf{IEEE.STD\_LOGIC\_UNSIGNED:} Proporciona operadores aritméticos y de comparación para vectores de tipo \texttt{STD\_LOGIC\_VECTOR} tratados como números no signados.
\end{itemize}

\section{Entidad audio\_sos}
Define la interfaz del módulo con tres entradas (\texttt{bt1}, \texttt{bt2}, \texttt{bt3}) que representan los botones, una entrada de reloj (\texttt{clk}), y una salida de audio (\texttt{audio}) que es un vector de 2 bits.

\section{Arquitectura Behavioral}
La arquitectura contiene varias señales internas que controlan el flujo del programa:
\begin{itemize}
    \item \texttt{prev\_state\_bt1}, \texttt{prev\_state\_bt2}, \texttt{prev\_state\_bt3}: Almacenan el estado previo de los botones para detectar flancos de subida (transiciones de '1' a '0').
    \item \texttt{contador}: Cuenta ciclos de reloj para generar temporizaciones precisas.
    \item \texttt{dac\_out}: Señal de salida que se alterna para generar la onda de audio.
    \item \texttt{bit\_index\_increment}: Controla cuándo se debe avanzar al siguiente bit de la secuencia.
    \item \texttt{bit\_time}: Controla la duración de cada bit en la secuencia.
    \item \texttt{bit\_index}: Índice que apunta al bit actual en la secuencia de bits.
    \item \texttt{bit\_sequence}: Almacena la secuencia de bits en Morse que se debe reproducir.
    \item \texttt{bit\_tone\_period}: Controla la frecuencia de la señal de salida (modula la onda).
\end{itemize}

\section{Proceso Principal}
Este proceso se ejecuta en cada flanco ascendente del reloj (\texttt{rising\_edge(clk)}). Su funcionamiento se describe a continuación:

\subsection{Contador (\texttt{contador}):}
\begin{itemize}
    \item Incrementa en cada ciclo de reloj.
    \item Cuando alcanza 60000 (el valor configurado), se restablece a 0 y se verifica el estado de los botones.
\end{itemize}

\subsection{Detección de Flancos de Subida:}
\begin{itemize}
    \item Para cada botón, si se detecta una transición de '1' a '0', se activa \texttt{bit\_index\_increment} y se carga la secuencia de bits correspondiente en \texttt{bit\_sequence}.
    \item Las secuencias están codificadas en Morse:
    \begin{itemize}
        \item \texttt{bt1} (HELP): \texttt{".... . .-.. .--."}
        \item \texttt{bt2} (SOS): \texttt{"... --- ..."}
        \item \texttt{bt3} (JOSE): \texttt{".--- --- ... ."}
    \end{itemize}
    \item \texttt{prev\_state\_bt1}, \texttt{prev\_state\_bt2}, y \texttt{prev\_state\_bt3} se actualizan con el estado actual del botón.
\end{itemize}

\subsection{Manejo de Secuencias de Bits:}
\begin{itemize}
    \item \texttt{bit\_time} controla la duración de cada bit. Cuando alcanza 1600000, se restablece y avanza al siguiente bit en la secuencia.
    \item \texttt{bit\_index} se incrementa para avanzar en la secuencia. Si se ha alcanzado el final de la secuencia o \texttt{bit\_index\_increment} está activo, se reinicia \texttt{bit\_index} a 0.
\end{itemize}

\subsection{Generación de la Señal de Audio (\texttt{dac\_out}):}
\begin{itemize}
    \item \texttt{bit\_tone\_period} se incrementa y se utiliza para modular la frecuencia de la señal de salida.
    \item Cuando \texttt{bit\_tone\_period} alcanza 16666, se verifica el bit actual en \texttt{bit\_sequence}:
    \begin{itemize}
        \item Si es '1', \texttt{dac\_out} alterna su valor (creando una onda).
        \item Si es '0', \texttt{dac\_out} se establece en '0'.
    \end{itemize}
\end{itemize}

\subsection{Asignación de la Salida (\texttt{audio}):}
La salida \texttt{audio} es un vector de 2 bits, ambos configurados con el valor de \texttt{dac\_out}. Esto genera una señal de audio en ambas líneas del vector de salida.

\section{Funcionamiento General}
Cuando se presiona un botón, se selecciona una secuencia de bits Morse que se reproduce como una señal de audio. La secuencia se reproduce bit a bit, donde '1' genera un tono y '0' genera silencio. Esta señal se envía a la salida \texttt{audio}, permitiendo que el sistema emita un mensaje codificado en Morse.

Este código está diseñado para implementarse en una FPGA, donde las señales de entrada provienen de botones físicos, y la señal de salida \texttt{audio} se puede conectar a un DAC o altavoz para reproducir los tonos correspondientes.
