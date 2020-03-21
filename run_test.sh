count=4

for (( i=0; i<$count; i+=1 ))
do
    echo "Starting client..."
    ./Client/application.linux-arm64/Client &
done

echo "Starting server..."
python3 ./Server/main.py wait $count
    
echo "Test complete!" 
