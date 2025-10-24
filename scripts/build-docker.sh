#!/bin/bash

# ChartDB Docker Build Script with Ollama Integration
# This script builds ChartDB with Ollama LLM support

echo "🚀 Building ChartDB with Ollama Integration"
echo "=========================================="

# Configuration
CHARTDB_IMAGE="chartdb-ollama"
OLLAMA_MODEL="llama3.2:latest"
OLLAMA_ENDPOINT="http://localhost:11434/v1"

echo ""
echo "📋 Configuration:"
echo "   ChartDB Image: $CHARTDB_IMAGE"
echo "   Ollama Model: $OLLAMA_MODEL"
echo "   Ollama Endpoint: $OLLAMA_ENDPOINT"
echo ""

# Build ChartDB with Ollama configuration
echo "🔨 Building ChartDB Docker image..."
docker build \
  --build-arg VITE_OPENAI_API_ENDPOINT="$OLLAMA_ENDPOINT" \
  --build-arg VITE_LLM_MODEL_NAME="$OLLAMA_MODEL" \
  --build-arg VITE_HIDE_CHARTDB_CLOUD="false" \
  --build-arg VITE_DISABLE_ANALYTICS="true" \
  --build-arg VITE_APP_URL="http://localhost:8081" \
  
  --build-arg VITE_HOST_URL="http://localhost:8081" \
  -t "$CHARTDB_IMAGE" .

if [ $? -eq 0 ]; then
    echo "✅ ChartDB image built successfully!"
    echo ""
    echo "🐳 Available Docker images:"
    docker images | grep chartdb
    echo ""
echo "🚀 To run ChartDB with local Ollama:"
echo "   # Make sure Ollama is running locally:"
echo "   ollama serve"
echo ""
echo "   # Then start ChartDB:"
echo "   docker-compose up -d"
echo ""
echo "🌐 Access ChartDB at: http://localhost:8081"
echo "🤖 Local Ollama API at: http://localhost:11434"
else
    echo "❌ Build failed!"
    exit 1
fi
