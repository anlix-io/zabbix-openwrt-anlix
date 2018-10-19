/*
** Zabbix
** Copyright (C) 2001-2017 Zabbix SIA
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/

#ifndef ZABBIX_ZBXNIX_H
#define ZABBIX_ZBXNIX_H

#if defined(HAVE_POLARSSL) || defined(HAVE_MBEDTLS21) || defined(HAVE_GNUTLS) || defined(HAVE_OPENSSL)
int	zbx_coredump_disable(void);
#endif

#endif	/* ZABBIX_ZBXNIX_H */
