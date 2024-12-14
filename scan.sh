# Step 1: Generate a random file name
RANDOM_FILENAME="zap_report_$(date +%s)_$(shuf -i 1000-9999 -n 1).json"

# Step 2: Run the ZAP scan with the generated random file name, silencing all other output
docker run -v /root/zap:/zap/wrk/:rw -t zaproxy/zap-stable:latest \
  zap-api-scan.py -t $SWAGGER_DOC_URL -f openapi -J /zap/wrk/"$RANDOM_FILENAME" \
  > /dev/null 2>&1

# Step 3: Echo the content of the report file (only the content)
echo "$(cat /root/zap/$RANDOM_FILENAME)"

# Step 4: Remove the report file after use
rm /root/zap/"$RANDOM_FILENAME"
