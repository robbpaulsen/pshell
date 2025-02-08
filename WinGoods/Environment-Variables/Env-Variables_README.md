# Variables de Entorno en Windows/PowerShell

## Definicion

A palabras simples se pueden definir como un objeto al cual se le asigna un valor, este valor es 
definido por el usuario que le dara un uso a esa variable. Su sintaxys es muy particular pero difiere
por muy poco en cada plataforma `Sistema Operativo` en donde se implementen. Windows PowerShell tiene
muchas similitudes con el estilo y syntaxis de Python y al igual que este lenguaje de programacion
el usar espacios en los bloques de codigo para una lectura mas eficiente del codigo la definicion
de las variables es casi igual en donde el nombre de la variable es precedida por un `$` seguido por
el nombre asignado un "< ESPACIO >" y se indica con un "=" y seguido por otro espacio y rodeado
de comillas dobles `" " ` o sencillas `' '`.

El caso de uso de cada una de las comillas es particular a la tarea u objetivo que el
usuario/desarrollador busca cumplir. Las comillas dobles le indican al interprete "PowerShell" 
que el valor que se asigna a la variable es de `TYPE` o "Tipo" "Cadena/String" por lo que el interprete
en el caso de que la variable contenga uso o definicion explicita de la ejecucion de un evento o comando
no la ejecute y que solo expanda el valor que contiene la variable hacia el siguiente paso del bloque
de codigo para continuar con el flujo de trabajo. Y las comillas sencillas le indican al interprete 
de PowerShell que este alerta y/o buscando este tipo de contenido en la variable por que debera
ejecutarlo, a diferencia de las otras commillas esta variable no se expande por completo solo
le pasa su valor/contenido al interprete para que el siguiente bloque de codigo pueda seguir,
de lo contrario se vera interrumpido.