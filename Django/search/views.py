from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from elasticsearch import Elasticsearch
from elasticsearch.exceptions import NotFoundError, AuthenticationException
import json
import urllib3
import os

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Initialize Elasticsearch client with SSL verification disabled
es = Elasticsearch(
    [os.getenv("ELASTICSEARCH_HOST", "https://104.154.91.24:9200/")],
    http_auth=(
        os.getenv("ELASTICSEARCH_USER", "elastic"),
        os.getenv("ELASTICSEARCH_PASSWORD", "X0RL9SbOpQRo9Yph9Z_J"),
    ),
    verify_certs=False,  # Disable SSL certificate verification
)


class InsertDataView(APIView):
    def post(self, request):
        try:
            index_name = request.data.get('index_name')
            document = request.data.get('document')

            if not index_name:
                return Response({"error": "Index name is required"}, status=status.HTTP_400_BAD_REQUEST)
            if not document:
                return Response({"error": "Document data is required"}, status=status.HTTP_400_BAD_REQUEST)

            # Log the incoming data for debugging
            print(f"Inserting document into index: {index_name}")
            print(f"Document: {json.dumps(document, indent=2)}")

            response = es.index(index=index_name, body=document)
            return Response({"message": "Document inserted successfully", "result": response}, status=status.HTTP_201_CREATED)

        except AuthenticationException:
            return Response({"error": "Elasticsearch authentication failed. Check credentials."},
                            status=status.HTTP_401_UNAUTHORIZED)
        except NotFoundError:
            return Response({"error": "Index not found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print(f"Error inserting data: {str(e)}")
            return Response({"error": "An internal server error occurred"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SearchByLocationView(APIView):
    def post(self, request):
        try:
            lat = request.data.get('lat')
            lon = request.data.get('lon')
            distance = request.data.get('distance')
            index_name = request.data.get('index_name', 'qualitynet/_search')
            network_type = request.data.get('networkType')

            if not all([lat, lon, distance, network_type]):
                return Response({"error": "Missing required parameters: lat, lon, distance, networkType"},
                                status=status.HTTP_400_BAD_REQUEST)

            query = {
                "size": 10,  # Fetch 10 results
                "query": {
                    "bool": {
                        "must": [
                            {
                                "geo_distance": {
                                    "distance": distance,
                                    "location": {"lat": lat, "lon": lon},
                                }
                            },
                            {"term": {"networkType.keyword": network_type}},
                        ]
                    }
                },
                "sort": [{"downloadSpeed": {"order": "desc"}}],
            }

            print(f"Executing query: {json.dumps(query, indent=2)}")  # Debugging logs
            response = es.search(index=index_name, body=query)
            print(f"Elasticsearch Response: {response}")

            return Response({"message": "Search successful", "result": response['hits']['hits']},
                            status=status.HTTP_200_OK)

        except AuthenticationException:
            return Response({"error": "Elasticsearch authentication failed. Check credentials."},
                            status=status.HTTP_401_UNAUTHORIZED)
        except NotFoundError:
            return Response({"error": "Index not found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print(f"Error performing search: {str(e)}")
            return Response({"error": "An internal server error occurred"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SearchByOperatorView(APIView):
    def post(self, request):
        try:
            operator = request.data.get('operator')

            if not operator:
                return Response({"error": "Operator is required"}, status=status.HTTP_400_BAD_REQUEST)

            # Normalize operator name (adjust based on actual data)
            if operator == 'Mauritel':
                operator = operator + ' Jawal Moov'
            elif operator == 'Chinguitel':
                operator = operator + ' mauritani'

            query = {
                "size": 10,  # Fetch top 10 results
                "query": {
                    "match": {
                        "operator": operator
                    }
                },
                "sort": [
                    {
                        "downloadSpeed": {
                            "order": "desc"
                        }
                    }
                ]
            }

            print(f"Executing query for operator: {operator}")
            response = es.search(index="qualitynet", body=query)
            print(f"Elasticsearch Response: {response}")

            return Response({"message": "Search successful", "result": response['hits']['hits']},
                            status=status.HTTP_200_OK)

        except AuthenticationException:
            return Response({"error": "Elasticsearch authentication failed. Check credentials."},
                            status=status.HTTP_401_UNAUTHORIZED)
        except NotFoundError:
            return Response({"error": "Index not found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print(f"Error performing search: {str(e)}")
            return Response({"error": "An internal server error occurred"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)