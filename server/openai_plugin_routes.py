import os
from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse, PlainTextResponse, FileResponse

router = APIRouter()

# Define a generic function to handle file requests
async def handle_file_request(file_path: str, response_class):
    try:
        # Read the contents of the file
        with open(file_path, "r") as f:
            file_contents = f.read()

        # Expand environment variables in the file contents
        expanded_contents = os.path.expandvars(file_contents)

        # Create the response with the expanded contents
        response = response_class(content=expanded_contents)

        # Set the Cache-Control header to enable caching
        # In this example, the max-age directive is set to 3600 seconds (1 hour)
        response.headers["Cache-Control"] = "public, max-age=3600"

        # Return the response
        return response
    except FileNotFoundError:
        # If the file is not found, return a 404 error
        raise HTTPException(status_code=404, detail="File not found")

# Define a route to handle requests to /.well-known/ai-plugin.json
@router.get("/.well-known/ai-plugin.json")
async def ai_plugin_json():
    return await handle_file_request(".well-known/ai-plugin.json", JSONResponse)

# Define a route to handle requests to /.well-known/openapi.yaml
@router.get("/.well-known/openapi.yaml")
async def openapi_yaml():
    return await handle_file_request(".well-known/openapi.yaml", PlainTextResponse)

# Define a route to handle requests to /.well-known/logo.png
@router.get("/.well-known/logo.png")
async def logo_png():
    # Create the FileResponse
    response = FileResponse(".well-known/logo.png")

    # Set the Cache-Control header to enable caching
    response.headers["Cache-Control"] = "public, max-age=3600"

    # Return the response
    return response
