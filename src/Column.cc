// +------------------------------------------------------------------+
// |             ____ _               _        __  __ _  __           |
// |            / ___| |__   ___  ___| | __   |  \/  | |/ /           |
// |           | |   | '_ \ / _ \/ __| |/ /   | |\/| | ' /            |
// |           | |___| | | |  __/ (__|   <    | |  | | . \            |
// |            \____|_| |_|\___|\___|_|\_\___|_|  |_|_|\_\           |
// |                                                                  |
// | Copyright Mathias Kettner 2012             mk@mathias-kettner.de |
// +------------------------------------------------------------------+
//
// This file is part of Check_MK.
// The official homepage is at http://mathias-kettner.de/check_mk.
//
// Updated 2012 by Max Sikström - op5: Added compare interface
//
// check_mk is free software;  you can redistribute it and/or modify it
// under the  terms of the  GNU General Public License  as published by
// the Free Software Foundation in version 2.  check_mk is  distributed
// in the hope that it will be useful, but WITHOUT ANY WARRANTY;  with-
// out even the implied warranty of  MERCHANTABILITY  or  FITNESS FOR A
// PARTICULAR PURPOSE. See the  GNU General Public License for more de-
// ails.  You should have  received  a copy of the  GNU  General Public
// License along with GNU Make; see the file  COPYING.  If  not,  write
// to the Free Software Foundation, Inc., 51 Franklin St,  Fifth Floor,
// Boston, MA 02110-1301 USA.

#include "Column.h"
#include "logger.h"


Column::Column(string name, string description, int indirect_offset)
  : _name(name)
  , _description(description)
  , _indirect_offset(indirect_offset)
{
}

void *Column::shiftPointer(void *data)
{
    if (!data)
        return 0;

    else if (_indirect_offset >= 0) {
        // add one indirection level
        // indirect_offset is place in structure, where
        // pointer to real object is
        return *((void **)((char *)data + _indirect_offset));
    }
    else // no indirection
        return data;
}

int Column::compare(void *dataa, void *datab, Query *query) {
    /* Column cant be compared. Assume everything is equal. Makes column
     * unsorted. Override this function for comparable types
     */
    return 0;
}

