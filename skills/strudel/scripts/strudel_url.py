#!/usr/bin/env python3
"""
Strudel URL encoder/decoder

Encodes Strudel code to base64 URL format or decodes URLs back to code.
"""

import base64
import sys
import urllib.parse


def encode_strudel(code: str) -> str:
    """
    Encode Strudel code to base64 URL format.

    Args:
        code: The Strudel JavaScript code to encode

    Returns:
        Full Strudel URL with encoded code
    """
    # Encode to UTF-8 bytes then base64
    encoded_bytes = base64.b64encode(code.encode('utf-8'))
    encoded_str = encoded_bytes.decode('utf-8')

    # URL encode the base64 string
    url_encoded = urllib.parse.quote(encoded_str, safe='')

    return f"https://strudel.cc/#{url_encoded}"


def decode_strudel(url: str) -> str:
    """
    Decode a Strudel URL back to code.

    Args:
        url: Full Strudel URL or just the base64 hash fragment

    Returns:
        Decoded Strudel code
    """
    # Extract hash fragment if full URL provided
    if '#' in url:
        encoded_str = url.split('#', 1)[1]
    else:
        encoded_str = url

    # URL decode first
    url_decoded = urllib.parse.unquote(encoded_str)

    # Base64 decode
    decoded_bytes = base64.b64decode(url_decoded)
    code = decoded_bytes.decode('utf-8')

    return code


def main():
    if len(sys.argv) < 3:
        print("Usage:")
        print("  Encode: python strudel_url.py encode <code>")
        print("  Decode: python strudel_url.py decode <url>")
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == 'encode':
        code = sys.argv[2]
        url = encode_strudel(code)
        print(url)
    elif command == 'decode':
        url = sys.argv[2]
        code = decode_strudel(url)
        print(code)
    else:
        print(f"Unknown command: {command}")
        print("Use 'encode' or 'decode'")
        sys.exit(1)


if __name__ == '__main__':
    main()
