#!/system/bin/sh
MODDIR=${0%/*}

echo "
    ____  _____   ________
   / __ \/  _/ | / / ____/
  / /_/ // //  |/ / / __  
 / ____// // /|  / /_/ /  
/_/   /___/_/ |_/\____/   
                          
"
echo "- Refreshing NetBlock rules..."
sh "$MODDIR/service.sh" &
echo "- Refresh triggered ✓"
