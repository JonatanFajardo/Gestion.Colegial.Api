# === Build (.NET 6, solución multiproyecto) ===
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY . ./
RUN dotnet publish "Gestion.Colegial.Api/Gestion.Colegial.Api.csproj" -c Release -o /app /p:UseAppHost=false

# === Runtime ===
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app ./
ENV ASPNETCORE_URLS=http://0.0.0.0:5076
EXPOSE 5076
ENTRYPOINT ["dotnet", "Gestion.Colegial.Api.dll"]
