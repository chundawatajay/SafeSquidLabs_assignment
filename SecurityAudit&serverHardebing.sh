#!/bin/bash

# User and Group Audits

list_users_and_groups() {
    echo "Listing all users:"
    cut -d: -f1 /etc/passwd
    echo "Listing all groups:"
    cut -d: -f1 /etc/group
}

check_uid_0_users() {
    echo "Checking for non-root users with UID 0:"
    awk -F: '($3 == 0) {print $1}' /etc/passwd | grep -v "^root$"
}

check_weak_passwords() {
    echo "Checking for users without passwords or with weak passwords:"
    awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow
}

# File and Directory Permissions

check_world_writable() {
    echo "Scanning for world-writable files and directories:"
    find / -xdev -type f -perm -0002
    find / -xdev -type d -perm -0002
}

check_ssh_permissions() {
    echo "Checking .ssh directory permissions:"
    find /home -type d -name ".ssh" -exec chmod 700 {} \;
    find /home -type f -name "authorized_keys" -exec chmod 600 {} \;
}

check_suid_sgid() {
    echo "Checking for files with SUID/SGID bits set:"
    find / -perm /6000 -type f
}

# Service Audits

list_running_services() {
    echo "Listing all running services:"
    systemctl list-units --type=service --state=running
}

check_unnecessary_services() {
    echo "Checking for unnecessary services:"
    local services=("cups" "nfs-server" "avahi-daemon")
    for service in "${services[@]}"; do
        systemctl is-active --quiet "$service" && echo "$service is running"
    done
}

check_critical_services() {
    echo "Ensuring critical services are running:"
    local critical_services=("sshd" "iptables")
    for service in "${critical_services[@]}"; do
        systemctl is-active --quiet "$service" || echo "$service is not running"
    done
}

# Firewall and Network Security

check_firewall() {
    echo "Checking if firewall is active:"
    if command -v ufw >/dev/null 2>&1; then
        ufw status
    elif command -v iptables >/dev/null 2>&1; then
        iptables -L -v
    else
        echo "No firewall detected"
    fi
}

check_open_ports() {
    echo "Checking for open ports:"
    ss -tuln
}

check_network_security() {
    echo "Checking for IP forwarding and other insecure settings:"
    sysctl net.ipv4.ip_forward
    sysctl net.ipv4.conf.all.accept_redirects
}

# IP and Network Configuration Checks

check_ip_addresses() {
    echo "Checking IP addresses:"
    ip -o -4 addr show | awk '{print $2 " " $4}' | while read -r iface ip; do
        if [[ "$ip" =~ ^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.168\.* ]]; then
            echo "$iface: Private IP - $ip"
        else
            echo "$iface: Public IP - $ip"
        fi
    done
}

# Security Updates and Patching

check_security_updates() {
    echo "Checking for available security updates:"
    if command -v apt-get >/dev/null 2>&1; then
        apt-get -s upgrade | grep -i security
    elif command -v yum >/dev/null 2>&1; then
        yum check-update --security
    fi
}

# Log Monitoring

check_suspicious_logs() {
    echo "Checking for suspicious log entries:"
    grep "Failed password" /var/log/auth.log | tail -n 10
}

# Server Hardening Steps

harden_ssh() {
    echo "Hardening SSH configuration:"
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl reload sshd
}

disable_ipv6() {
    echo "Disabling IPv6:"
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p
}

# Custom Security Checks

custom_security_checks() {
    echo "Running custom security checks:"
    # Implement custom checks here
}

# Reporting and Alerting

generate_report() {
    echo "Generating security audit report:"
    # Compile all outputs into a report
}

send_alerts() {
    echo "Sending alerts if critical vulnerabilities found:"
    # Implement email notification logic
}



main() {
    list_users_and_groups
    check_uid_0_users
    check_weak_passwords
    check_world_writable
    check_ssh_permissions
    check_suid_sgid
    list_running_services
    check_unnecessary_services
    check_critical_services
    check_firewall
    check_open_ports
    check_network_security
    check_ip_addresses
    check_security_updates
    check_suspicious_logs
    harden_ssh
    disable_ipv6
    custom_security_checks
    generate_report
    
}

main "$@"
