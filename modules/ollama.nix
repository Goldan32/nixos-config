{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    # Pulls the model when the service starts (optional, you can also `ollama pull` manually)
    # loadModels = [ "qwen3-coder:30b" ];

    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768"; # agents need a big context; Ollama's default is small
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # halves KV-cache memory
      OLLAMA_KEEP_ALIVE = "-1"; # keep model loaded, avoids reloading on every request
    };
  };
}
