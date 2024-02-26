#!/bin/bash

# VOLUMENES
echo "Eliminando volumen Tomcat..."
openstack volume delete volume-tomcat
echo "Volumen Tomcat eliminado correctamente!"
echo ""

echo "Eliminando volumen MySQL..."
openstack volume delete volume-mysql
echo "Volumen MySQL eliminado correctamente!"
echo ""

# GRUPO DE SEGURIDAD
# Esperar a que no haya ninguna instancia usando el grupo de seguridad
echo "Eliminando Grupo de Seguridad..."
openstack security group delete proyecto11-security-group
echo "Grupo de Seguridad eliminado correctamente!"
echo ""

# ROUTER
# Desvincular la subred interna del router
echo "Desvinculando SubNet-Interna del Router..."
openstack router remove subnet proyecto11-router proyecto11-subnet
echo "SubNet-Interna desvinculada correctamente!"
echo ""

# Desvincular la red externa del router
echo "Desvinculando Red-Externa del Router..."
openstack router unset --external-gateway proyecto11-router
echo "Red-Externa desvinculada correctamente!"
echo ""

# Eliminar el router
echo "Eliminando Router..."
openstack router delete proyecto11-router
echo "Router eliminado correctamente!"
echo ""

# SUBNET
echo "Eliminando SubNet..."
openstack subnet delete proyecto11-subnet
echo "SubNet eliminada correctamente!"
echo ""

# NETWORK
echo "Eliminando Network..."
openstack network delete proyecto11-network
echo "Network eliminada correctamente!"
echo ""

echo "Todos los recursos han sido eliminados correctamente."

