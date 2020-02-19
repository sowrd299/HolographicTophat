count=4

echo "Starting server..."
python3 ./Server/main.py wait $count &

for (( i=0; i<$count; i+=1 ))
do
    echo "Starting client..."
    ./Client/application.linux-arm64/Client &
done
    
echo "Test started...."