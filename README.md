# Declaraciones Iniciales

## Librerías y Paquetes:

- **IEEE.STD_LOGIC_1164:** Define tipos de datos estándar como `STD_LOGIC` y `STD_LOGIC_VECTOR`, utilizados para manejar señales digitales.
- **IEEE.STD_LOGIC_UNSIGNED:** Proporciona operadores aritméticos y de comparación para vectores de tipo `STD_LOGIC_VECTOR` tratados como números no signados.

# Entidad `audio_sos`

Define la interfaz del módulo con tres entradas (`bt1`, `bt2`, `bt3`) que representan los botones, una entrada de reloj (`clk`), y una salida de audio (`audio`) que es un vector de 2 bits.

# Arquitectura Behavioral

La arquitectura contiene varias señales internas que controlan el flujo del programa:

- `prev_state_bt1`, `prev_state_bt2`, `prev_state_bt3`: Almacenan el estado previo de los botones para detectar flancos de subida (transiciones de '1' a '0').
- `contador`: Cuenta ciclos de reloj para generar temporizaciones precisas.
- `dac_out`: Señal de salida que se alterna para generar la onda de audio.
- `bit_index_increment`: Controla cuándo se debe avanzar al siguiente bit de la secuencia.
- `bit_time`: Controla la duración de cada bit en la secuencia.
- `bit_index`: Índice que apunta al bit actual en la secuencia de bits.
- `bit_sequence`: Almacena la secuencia de bits en Morse que se debe reproducir.
- `bit_tone_period`: Controla la frecuencia de la señal de salida (modula la onda).

# Proceso Principal

Este proceso se ejecuta en cada flanco ascendente del reloj (`rising_edge(clk)`). Su funcionamiento se describe a continuación:

## Contador (`contador`):

- Incrementa en cada ciclo de reloj.
- Cuando alcanza 60000 (el valor configurado), se restablece a 0 y se verifica el estado de los botones.

## Detección de Flancos de Subida:

- Para cada botón, si se detecta una transición de '1' a '0', se activa `bit_index_increment` y se carga la secuencia de bits correspondiente en `bit_sequence`.
- Las secuencias están codificadas en Morse:
  - `bt1` (HELP): `".... . .-.. .--."`
  - `bt2` (SOS): `"... --- ..."`
  - `bt3` (JOSE): `".--- --- ... ."`
- `prev_state_bt1`, `prev_state_bt2`, y `prev_state_bt3` se actualizan con el estado actual del botón.

## Manejo de Secuencias de Bits:

- `bit_time` controla la duración de cada bit. Cuando alcanza 1600000, se restablece y avanza al siguiente bit en la secuencia.
- `bit_index` se incrementa para avanzar en la secuencia. Si se ha alcanzado el final de la secuencia o `bit_index_increment` está activo, se reinicia `bit_index` a 0.

## Generación de la Señal de Audio (`dac_out`):

- `bit_tone_period` se incrementa y se utiliza para modular la frecuencia de la señal de salida.
- Cuando `bit_tone_period` alcanza 16666, se verifica el bit actual en `bit_sequence`:
  - Si es '1', `dac_out` alterna su valor (creando una onda).
  - Si es '0', `dac_out` se establece en '0'.

## Asignación de la Salida (`audio`):

La salida `audio` es un vector de 2 bits, ambos configurados con el valor de `dac_out`. Esto genera una señal de audio en ambas líneas del vector de salida.

# Funcionamiento General

Cuando se presiona un botón, se selecciona una secuencia de bits Morse que se reproduce como una señal de audio. La secuencia se reproduce bit a bit, donde '1' genera un tono y '0' genera silencio. Esta señal se envía a la salida `audio`, permitiendo que el sistema emita un mensaje codificado en Morse.

Este código está diseñado para implementarse en una FPGA, donde las señales de entrada provienen de botones físicos, y la señal de salida `audio` se puede conectar a un DAC o altavoz para reproducir los tonos correspondientes.
