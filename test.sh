#!/bin/bash

# Nombre de la carpeta principal
CARPETA_PRINCIPAL="Empleados"
ARCHIVO_CSV="empleados.csv"
REPOSITORIO_GIT="https://github.com/CamaleonCuliao/Base-de-datos.git"

# Función para crear carpetas por cada empleado dentro de la carpeta "Empleados"
crear_carpetas_empleados() {
    if [ ! -d "$CARPETA_PRINCIPAL" ]; then
        mkdir "$CARPETA_PRINCIPAL"
        echo "Carpeta principal '$CARPETA_PRINCIPAL' creada."
    else
        echo "La carpeta principal '$CARPETA_PRINCIPAL' ya existe."
    fi

    while IFS=, read -r ID_Empleado Nombre Cargo Departamento Fecha_Ingreso Salario; do
        if [ "$ID_Empleado" != "ID_Empleado" ]; then
            NOMBRE_CARPETA=$(echo "$Nombre" | tr ' ' '_')
            RUTA_CARPETA="$CARPETA_PRINCIPAL/$NOMBRE_CARPETA"
            if [ ! -d "$RUTA_CARPETA" ]; then
                mkdir "$RUTA_CARPETA"
                echo "Carpeta '$RUTA_CARPETA' creada."
            else
                echo "La carpeta '$RUTA_CARPETA' ya existe."
            fi
        fi
    done < "$ARCHIVO_CSV"
}

# Función para agregar un nuevo empleado
anadir_empleado() {
    read -p "Ingrese el nombre del empleado: " nombre
    read -p "Ingrese el salario del empleado: " salario
    echo "Seleccione el cargo del empleado:"
    echo "1. Analista"
    echo "2. Directora"
    echo "3. Técnico"
    echo "4. Secretaria"
    echo "5. Gerente"
    echo "6. Desarrolladora"
    echo "7. Coordinador"
    echo "8. Contadora"
    echo "9. Ejecutiva"
    echo "10. Asistente"
    echo "11. Director"
    read -p "Seleccione una opción de cargo (1-11): " cargo_opcion
    case $cargo_opcion in
        1) cargo="Analista" ;;
        2) cargo="Directora" ;;
        3) cargo="Técnico" ;;
        4) cargo="Secretaria" ;;
        5) cargo="Gerente" ;;
        6) cargo="Desarrolladora" ;;
        7) cargo="Coordinador" ;;
        8) cargo="Contadora" ;;
        9) cargo="Ejecutiva" ;;
        10) cargo="Asistente" ;;
        11) cargo="Director" ;;
        *) echo "Opción no válida"; return ;;
    esac

    echo "Seleccione el departamento del empleado:"
    echo "1. TI"
    echo "2. RRHH"
    echo "3. Administración"
    echo "4. Marketing"
    read -p "Seleccione una opción de departamento (1-4): " dep_opcion
    case $dep_opcion in
        1) departamento="TI" ;;
        2) departamento="RRHH" ;;
        3) departamento="Administración" ;;
        4) departamento="Marketing" ;;
        *) echo "Opción no válida"; return ;;
    esac

    max_id=$(awk -F, 'NR > 1 {print $1}' "$ARCHIVO_CSV" | sort -n | tail -n 1)
    if [ -z "$max_id" ]; then
        nuevo_id=1
    else
        nuevo_id=$((max_id + 1))
    fi

    echo "$nuevo_id, $nombre, $cargo, $departamento, $(date +%Y-%m-%d), $salario" >> "$ARCHIVO_CSV"
    echo "Empleado $nombre agregado con éxito."

    NOMBRE_CARPETA=$(echo "$nombre" | tr ' ' '_')
    RUTA_CARPETA="$CARPETA_PRINCIPAL/$NOMBRE_CARPETA"
    if [ ! -d "$RUTA_CARPETA" ]; then
        mkdir "$RUTA_CARPETA"
        echo "Carpeta de $nombre creada en $RUTA_CARPETA"
    fi
}

# Función para eliminar un empleado
eliminar_empleado() {
    echo "Seleccione el empleado a eliminar:"
    awk -F, 'NR > 1 {print $1, $2, $3, $4}' "$ARCHIVO_CSV"
    read -p "Ingrese el ID del empleado a eliminar: " id_empleado

    if grep -q "^$id_empleado," "$ARCHIVO_CSV"; then
        sed -i "/^$id_empleado,/d" "$ARCHIVO_CSV"
        echo "Empleado con ID $id_empleado eliminado."

        nombre_empleado=$(awk -F, -v id="$id_empleado" '$1 == id {print $2}' "$ARCHIVO_CSV")
        if [ -d "$CARPETA_PRINCIPAL/$nombre_empleado" ]; then
            rm -r "$CARPETA_PRINCIPAL/$nombre_empleado"
            echo "Carpeta de $nombre_empleado eliminada."
        fi

        awk -F, 'NR > 1 {print $1, $2, $3, $4, $5, $6}' OFS=, "$ARCHIVO_CSV" | sort -t, -k1,1n > "$ARCHIVO_CSV.tmp" && mv "$ARCHIVO_CSV.tmp" "$ARCHIVO_CSV"
        echo "Los IDs se han reorganizado."
    else
        echo "Empleado no encontrado."
    fi
}

# Función para mostrar las estadísticas
mostrar_estadisticas() {
    echo "Seleccione el tipo de estadísticas que desea ver:"
    echo "1. Estadísticas de cargos"
    echo "2. Estadísticas de departamentos"
    echo "3. Estadísticas de salarios"
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) estadisticas_cargos ;;
        2) estadisticas_departamentos ;;
        3) estadisticas_salarios ;;
        *) echo "Opción no válida";;
    esac
}

estadisticas_cargos() {
    declare -A cargos
    while IFS=, read -r ID_Empleado Nombre Cargo Departamento Fecha_Ingreso Salario; do
        if [ "$ID_Empleado" != "ID_Empleado" ]; then
            ((cargos["$Cargo"]++))
        fi
    done < "$ARCHIVO_CSV"
    max_cargo=$(for c in "${!cargos[@]}"; do echo "${c},${cargos[$c]}"; done | sort -t, -k2 -n | tail -n 1)
    min_cargo=$(for c in "${!cargos[@]}"; do echo "${c},${cargos[$c]}"; done | sort -t, -k2 -n | head -n 1)
    echo "Cargo con más empleados: $max_cargo"
    echo "Cargo con menos empleados: $min_cargo"
}

estadisticas_departamentos() {
    declare -A departamentos
    while IFS=, read -r ID_Empleado Nombre Cargo Departamento Fecha_Ingreso Salario; do
        if [ "$ID_Empleado" != "ID_Empleado" ]; then
            ((departamentos["$Departamento"]++))
        fi
    done < "$ARCHIVO_CSV"
    max_departamento=$(for d in "${!departamentos[@]}"; do echo "${d},${departamentos[$d]}"; done | sort -t, -k2 -n | tail -n 1)
    min_departamento=$(for d in "${!departamentos[@]}"; do echo "${d},${departamentos[$d]}"; done | sort -t, -k2 -n | head -n 1)
    echo "Departamento con más empleados: $max_departamento"
    echo "Departamento con menos empleados: $min_departamento"
}

estadisticas_salarios() {
    salarios=()
    while IFS=, read -r ID_Empleado Nombre Cargo Departamento Fecha_Ingreso Salario; do
        if [ "$ID_Empleado" != "ID_Empleado" ]; then
            salarios+=($Salario)
        fi
    done < "$ARCHIVO_CSV"
    max_salario=$(printf "%s\n" "${salarios[@]}" | sort -n | tail -n 1)
    min_salario=$(printf "%s\n" "${salarios[@]}" | sort -n | head -n 1)
    echo "El salario más alto es: $max_salario"
    echo "El salario más bajo es: $min_salario"
}

# Función para subir los cambios al repositorio de GitHub
subir_a_repositorio() {
    echo "Subiendo los cambios al repositorio de GitHub..."

    # Verificar si Git está instalado
    if ! command -v git &> /dev/null; then
        read -p "Git no está instalado. ¿Desea instalarlo? (s/n): " respuesta
        if [ "$respuesta" == "s" ]; then
            echo "Instalando Git..."
            sudo apt update
            sudo apt install git -y
        else
            echo "No se puede continuar sin Git."
            return
        fi
    fi

    # Verificar si el directorio está inicializado como un repositorio de Git
    if [ ! -d ".git" ]; then
        git init
        git remote add origin "$REPOSITORIO_GIT"
    fi

    git add .
    git commit -m "Actualización de base de datos"
    git push origin master
    echo "Cambios subidos al repositorio con éxito."
}

# Función principal del menú
menu() {
    while true; do
        echo "Bienvenido a la base de datos de la empresa"
        echo "1. Crear carpetas de empleados"
        echo "2. Añadir empleado"
        echo "3. Eliminar empleado"
        echo "4. Ver estadísticas"
        echo "5. Subir cambios a GitHub"
        echo "6. Salir"
        read -p "Seleccione una opción: " opcion

        case $opcion in
            1) crear_carpetas_empleados ;;
            2) anadir_empleado ;;
            3) eliminar_empleado ;;
            4) mostrar_estadisticas ;;
            5) subir_a_repositorio ;;
            6) echo "Saliendo..."; break ;;
            *) echo "Opción no válida";;
        esac
    done
}

# Ejecutar el menú
menu

