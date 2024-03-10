# NETWORK
# Crear el network
echo "Creando Network..."
openstack network create proyecto11-network
echo ""

echo "Creando SubNet..."
# Asociar
openstack subnet create \
    --network proyecto11-network \
    --dns-nameserver 8.8.8.8 \
    --subnet-range 10.0.0.0/24 \
     proyecto11-subnet
echo ""


# ROUTER
# Crear el router
echo "Creando Router..."
openstack router create proyecto11-router
echo ""


# INTERFACES
# Agregar una interfaz del router a la red interna
echo "Vinculando Red-Interna a Router"
openstack router add subnet proyecto11-router proyecto11-subnet
echo ""

# Obtener el ID de la red externa ("external-network")
red_externa_id=$(openstack network show external-network -f value -c id)
echo "Red externa ID: $red_externa_id"
echo ""

# Agregar una interfaz del router a la red externa
echo "Vinculando SubNet-Externa a Router"
openstack router set --external-gateway $red_externa_id proyecto11-router
echo ""


# GRUPO DE SEGURIDAD
# Crear grupo de seguridad
echo "Creando Grupo de Seguridad"
openstack security group create proyecto11-security-group
echo ""

# Regla para permitir tráfico SSH (puerto 22)
echo "Creando regla seguridad SSH"
openstack security group rule create --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""

# Regla para permitir tráfico ICMP
echo "Creando regla de seguridad ICMP"
openstack security group rule create --protocol icmp proyecto11-security-group
echo ""

# Regla para permitir tráfico HTTP al puerto 8080
echo "Creando regla de seguridad HTTP"
openstack security group rule create --protocol tcp --dst-port 8080:8080 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""

# Regla para permitir tráfico al puerto 3306 (MySQL)
echo "Creando regla de seguridad MySQL"
openstack security group rule create --protocol tcp --dst-port 3306:3306 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""

# Regla para permitir tráfico al puerto 5001 (iperf)
echo "Creando regla de seguridad IPERF"
openstack security group rule create --protocol tcp --dst-port 5001:5001 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""


# VOLUMEN
# Tomcat
echo "Creando volumen Tomcat..."
openstack volume create --size 1 proyecto11-volume-tomcat

status_volume_tomcat=$(openstack volume show proyecto11-volume-tomcat -f value -c status)
# Bucle while que se ejecutará mientras la variable sea diferente de "available"
while [ "$status_volume_tomcat" != "available" ]; do
    echo "Esperando a que el Volumen de Tomcat este disponible..."

    new_status=$(openstack volume show proyecto11-volume-tomcat -f value -c status)
    status_volume_tomcat="$new_status"

    sleep 2
done
echo "Volumen Tomcat creado correctamente!"

#MySQL
echo "Creando volumen MySQL..."
openstack volume create --size 1 proyecto11-volume-mysql

status_volume_mysql=$(openstack volume show proyecto11-volume-mysql -f value -c status)
# Bucle while que se ejecutará mientras la variable sea diferente de "available"
while [ "$status_volume_mysql" != "available" ]; do
    echo "Esperando a que el Volumen de MySQL este disponible..."

    new_status=$(openstack volume show proyecto11-volume-mysql -f value -c status)
    status_volume_tomcat="$new_status"

    sleep 2
done
echo "Volumen MySQL creado correctamente!"


# INSTANCIAS

# Obtenemos el ID de la red interna para asociarlo a la instancia
red_interna_id=$(openstack network show proyecto11-network -f value -c id)

# Tomcat
echo "Creando instancia de Tomcat..."
openstack server create \
    --image ubuntu-focal \
    --flavor labs \
    --user-data tomcat.yml \
    --nic net-id=$red_interna_id\
    --security-group proyecto11-security-group \
    proyecto11-instance-tomcat

# Bucle para esperar a que la instancia esté disponible
status_server_tomcat=$(openstack server show proyecto11-instance-tomcat -f value -c status)
while [ "$status_server_tomcat" != "ACTIVE" ]; do
        echo "Esperando a que la Instancia de Tomcat este disponible..."
        new_status=$(openstack server show proyecto11-instance-tomcat -f value -c status)
        status_server_tomcat="$new_status"
        sleep 2
done
echo "Instancia de Tomcat creada correctamente!"
echo ""

# Asociar instancia a Volumen
# Obtener el ID de la instancia
tomcat_instancia_id=$(openstack server show -f value -c id proyecto11-instance-tomcat)
# Obtener el ID del volumen
tomcat_volumen_id=$(openstack volume show -f value -c id proyecto11-volume-tomcat)
# Asociar IDs
openstack server add volume $tomcat_instancia_id $tomcat_volumen_id

# MySQL
echo "Creando instancia de MySQL"
openstack server create \
    --image ubuntu-focal \
    --flavor labs \
    --user-data mysql.yml \
    --nic net-id=$red_interna_id\
    --security-group proyecto11-security-group \
    proyecto11-instance-mysql

# Bucle para esperar a que la instancia esté disponible
status_server_mysql=$(openstack server show proyecto11-instance-mysql -f value -c status)
while [ "$status_server_mysql" != "ACTIVE" ]; do
        echo "Esperando a que la Instancia de MySQL este disponible..."
        new_status=$(openstack server show proyecto11-instance-mysql -f value -c status)
        status_server_mysql="$new_status"
        sleep 2
done
echo "Instancia de MySQL creada correctamente!"
echo ""

# Asociar instancia a Volumen
# Obtener el ID de la instancia
myqsl_instancia_id=$(openstack server show -f value -c id proyecto11-instance-mysql)
# Obtener el ID del volumen
mysql_volumen_id=$(openstack volume show -f value -c id proyecto11-volume-mysql)
# Asociar IDs
echo "Asociando volumen a instancia de MySQL..."
openstack server add volume $myqsl_instancia_id $mysql_volumen_id
echo ""

# IP FLOTANTE
# Creacion de IP Flotante para cada instancia
echo "Creando IP Flotante para Tomcat..."
openstack floating ip create external-network --description proyecto11-floatingip-tomcat
echo ""

echo "Creando IP Flotante para MySQL..."
openstack floating ip create external-network --description proyecto11-floatingip-mysql
echo ""

# Obtener la IP asignada
echo "Obteniendo IP Flotante asignada para Tomcat..."
tomcat_floatingip=$(openstack floating ip list --long | grep "proyecto11-floatingip-tomcat" | awk '{print $4}')
echo ""

echo "Obteniendo IP Flotante asignada para MySQL"
mysql_floatingip=$(openstack floating ip list --long | grep "proyecto11-floatingip-mysql" | awk '{print $4}')
echo ""

# Asigna la IP
echo "Vincunlando IP Flotante a Instancia de Tomcat.."
openstack server add floating ip proyecto11-instance-tomcat $tomcat_floatingip
echo ""

echo "Vinculando IP Flotante a Instancia de MySQL..."
openstack server add floating ip proyecto11-instance-mysql $mysql_floatingip
echo ""