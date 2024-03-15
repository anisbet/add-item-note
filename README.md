# add-item-note
Shell for adding a note to an item in Symphony.

Test methods of automating the adding of custom notes to specific items.

There are three possible fields:
* CIRCNOTE
* PUBLIC
* STAFF

## Adding a Note
I have added a Staff note to item 31221376926965 : 'Test TWOSE message'

The hist file shows the following transactions on the title, one immediately after the first.
```bash
E202403151019403068R ^S04IVFFADMIN^FEEPLMNA^FcNONE^FWADMIN^NQ31221376926965^IQInspirational S PBK^daLC^ND3^NI2^Nz0^NHSTAFF^NETest TWOSE message^Fv3000000^^O
E202403151019413068R ^S10IVFFADMIN^FEEPLMNA^FcNONE^FWADMIN^NQ31221376926965^IQInspirational S PBK^IoADMIN^Fv3000000^^O
```

Translated that means:

```
3/15/2024,10:19:40 Station: 3068 Request: Sequence #: 04 Command: Edit Item Part B
station login user access:ADMIN  station library:EPLMNA  station login clearance:NONE  station user's user ID:ADMIN  item ID:31221376926965  call number:Inspirational S PBK  for storing list codes:LC  absolute entry or tag number:3  tag position or previous absolute entry number:2  next absolute entry number:0  entry ID or tag numbers:STAFF  entry or tag data:Test TWOSE message  Max length of transaction response:3000000  

3/15/2024,10:19:41 Station: 3068 Request: Sequence #: 10 Command: Edit Item Part B
station login user access:ADMIN  station library:EPLMNA  station login clearance:NONE  station user's user ID:ADMIN  item ID:31221376926965  call number:Inspirational S PBK  login name of who last modified catalog:ADMIN  Max length of transaction response:3000000  
```

## Removing a Note
To remove a message from the item the command codes are:

```bash
E202403151035083068R ^S14IVFFADMIN^FEEPLMNA^FcNONE^FWADMIN^NQ31221376926965^IQInspirational S PBK^daLC^ND3^NI2^Nz0^NHSTAFF^NE^Fv3000000^^O
E202403151035083068R ^S16IVFFADMIN^FEEPLMNA^FcNONE^FWADMIN^NQ31221376926965^IQInspirational S PBK^IoADMIN^Fv3000000^^O
```

Which translated is:

```
3/15/2024,10:35:08 Station: 3068 Request: Sequence #: 14 Command: Edit Item Part B
station login user access:ADMIN  station library:EPLMNA  station login clearance:NONE  station user's user ID:ADMIN  item ID:31221376926965  call number:Inspirational S PBK  for storing list codes:LC  absolute entry or tag number:3  tag position or previous absolute entry number:2  next absolute entry number:0  entry ID or tag numbers:STAFF  entry or tag data:  Max length of transaction response:3000000  

3/15/2024,10:35:08 Station: 3068 Request: Sequence #: 16 Command: Edit Item Part B
station login user access:ADMIN  station library:EPLMNA  station login clearance:NONE  station user's user ID:ADMIN  item ID:31221376926965  call number:Inspirational S PBK  login name of who last modified catalog:ADMIN  Max length of transaction response:3000000  
```

