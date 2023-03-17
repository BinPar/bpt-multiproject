# Como usar el template

## Creación del repositorio usando el template

Lo primero que haremos será crear el repositorio en BinPar usando el template, esto se puede hacer
de dos formas:
  - Desde el repositorio del template (https://github.com/BinPar/bpt-node) pulsar en el botón "Use this template"
  - Desde la opción de crear nuevo repositorio donde pone "Repository template" seleccionar "BinPar/bpt-node"

**Importante:** Crear el repositorio poniendo el Owner a "BinPar".
## Crear main

En la pestaña de "Code" pinchamos en el botón de "develop" donde se seleccionan las branches.

Escribimos main y pulsamos "Create branch: main from develop".

## Crear un team para el proyecto

Nos vamos a "Settings" y ahí a "Manage access".

A la derecha buscamos "Create team".

Creamos un nuevo team que se llame como el nombre del proyecto **sin ningún parent team y que sea visible**


## Clonar proyecto

En este punto nos clonamos ya el proyecto.

Adicionalmente modificaremos el package.json para cambiar por lo menos el `name` y la propiedad `description`.

También le dedicaremos unos minutos al README.md.

**IMPORTANTE**: Todos los archivos de código fuente con la excepción `tests` tienen que estar **obligatoriamente** incluidos en la carpeta `src`.

Además, si tenemos `nvm` instalado podemos ejecutar `npm run useNodeLTS` para usar la versión del .nvmrc

Para el siguiente punto vamos a necesitar ejecutar una vez el pipeline de Code quality por lo que con estos cambios haremos commit y crearemos nuestra primera pull request.

## Proteger la rama main

Dentro de "Settings" vamos a "Branches".

Ahí veremos "Branch protection rules" y al lado un botón de "Add rule".

En el interfaz que nos aparece dentro de "Branch name pattern" pondremos `main` y en "Protect matching branches" marcaremos "Require status checks to pass before merging" y dentro de esa buscaremos en el input los siguientes checks (recuerda: debes haber creado una pull request, sin necesidad de cerrarla, para que te aparezca el input que usarás para añadir los checks):
 - You shall not pass!
 - NPM Audit
 - Lint code
 - Type check
 - Run tests
 - Check k8s templates

Como **medida adicional** en proyectos que requieran que las **pull request estén aprobadas** por una persona adicional distinta del que la creó marcaremos también "Require a pull request before merging" y dentro de esta también marcaremos "Dismiss stale pull request approvals when new commits are pushed".

Si usamos la opción adicional la persona a cargo del proyecto debería tener el permiso de administrador del proyecto para poder hacer los merge que cree él mismo sin requerir la aprobación de otra parte.

Y pulsamos en "Create".


## Configurar el proyecto

Una vez hecho todo lo anterior lo único que nos falta es configurar los valores del proyecto. Para hacer esto en la ruta `k8s/templates/` hay un YAML que se llama `values.yml` que **es el único que vamos a modificar**. Dentro de la misma ruta tenemos el archivo `values-schema.yml` que contiene todos los campos configurables y los valores por defecto de los campos. No todos tienen valores por defecto y para sobrescribirlos lo haremos en el `values.yml`.

### values.yml
En el archivo `docs/examples/template-values.yml` tenéis un ejemplo de una configuración más avanzada que sobrescribe los ingress y añade config maps adicionales.

A continuación vemos lo que es cada configuración:

 - projectName: **Required** String - Indica el nombre del proyecto y se usa en los templates de k8s
 - resourceType: **Required** String - Sólo puede ser `Deploy`, `Job` o `CronJob`
 - hasIngress: **Required** Boolean - Indica cuándo se debe o no crear el ingress y todo lo relacionado con este.
 - useHttp: **Required** Boolean - Indica cuándo se debe o agregar el uso del puerto 80 a los pods (incluyendo el healthcheck obligatorio en este puerto por HTTP)
 - schedule: **Required if resourceType == "CronJob"** String - Aquí se indica el horario de ejecución del CronJob
 - namespace: String - El namespace de k8s en el que se despliegan los recursos (siempre se añade `-<environment>` al final automáticamente). Si se omite el namespace se infiere con el siguiente pattern `<projectName>-<environment>`.
 - defaultRootDomain: String - Por defecto `binpar.cloud`. Es el dominio sobre el que se construyen los subdominios para los distintos entornos.
 - productionDomain: String - El dominio que se utilizará para el entorno de `release`. Si se omite se infiere usando el defaultRootDomain.
 - environment: **No rellenar, omitir siempre**. Los pipelines del CI / CD rellenan este parámetro
 - healthcheckPath: String - Pro defecto `/healthcheck`. Es el endpoint donde k8s va a comprobar que la web está disponible periódicamente.
 - initialDelaySeconds: Int - Por defecto `4`. Configura esta propiedad del deploy. Es el tiempo que se retrasa la primera comprobación del healthcheck.
 - failureThreshold: Int - Por defecto `2`. Número de veces que puede fallar el healthcheck antes de marcarlo como no disponible.
 - timeoutSeconds: Int - Por defecto `5`. Número de segundos antes de que la prueba del healthcheck falle.
 - periodSeconds: Int - Por defecto `60`. Número de segundos entre pruebas de healthcheck.
 - baseReplicas: Int - Por defecto `2`. Número base de replicas del deploy.
 - releaseFactorReplicas: Int - Por defecto `2`. Multiplicador del número base de réplicas que se aplica a las versiones de release. Por ejemplo, con los valores por defecto el número de réplicas en release sería de `2 * 2 = 4`.
 - baseRAMRequest: Int - Por defecto `64`. Cantidad de mebibytes (MiB) que va a reservar nuestro deploy en versiones no release.
 - releaseFactorRAMRequest: Int - Por defecto `2`. Multiplicador de la cantidad base aplicado solo a los deploys de release.
 - baseRAMLimit: Int - Por defecto `256`. Cantidad de mebibytes (MiB) que no puede sobrepasar nuestro deploy. Si sobrepasa este umbral el proceso recibe un kill y se reinicia el pod en cuestión.
 - releaseFactorRAMLimit: Int - Por defecto `2`. Multiplicador de la cantidad base aplicado solo a los deploys de release.
 - baseCPURequest: Int - Por defecto `50`. Corresponde al número de ms de CPU que reserva (1000 sería una CPU completa).
 - releaseFactorCPURequest: Int - Por defecto `1`. Multiplicador que se aplica al valor base en los deploys de release
 - baseCPULimit: Int - Por defecto `500`. Corresponde al número de ms de CPU máximos que puede usar un pod del deploy (1000 sería una CPU completa y, en teoría, puede ser mayor).
 - releaseFactorCPULimit: Int - Por defecto `2`. Multiplicador que se aplica al valor base en los deploys de release
 - defaultConfig: YAML dict - Debe ser una serie de pares clave valor que se añadirán en el data del config map que se crea por defecto.
 - configMaps: YAML array - Aquí se puede especificar N config maps que se crearán adicionalmente. El formato de los miembros del array es un objeto que tiene una propiedad `name` que será el nombre del config map y una `data` que se corresponde con los datos que va a contener (se aplica directamente a la propiedad `data` del config map). Además se puede especificar una propiedad `environment` opcionalmente para que solo se despliegue en ese entorno.
 - ingressAnnotations: YAML dict - Aquí se pueden especificar distintas annotations para el ingress. Estas anotaciones se añaden a las que hay por defecto a no ser que especifiquen la misma clave en cuyo caso se sobrescriben.
 - ingressRules: YAML array - Aquí se puede especificar N reglas de ingress que sustituyen a las de por defecto. Adicionalmente si queremos utilizar el nombre del servicio que se crea automáticamente en el serviceName podemos ponerle el valor `"##DEFAULT_SERVICE_NAME"` (las comillas son necesarias para que lo tome como string).
 - ingressHosts: String array - Indicar aquí los hosts de los que se tiene que crear certificado SSL. Se meten en la propiedad `tls` del ingress.
 - additionalDeployEnvSources: YAML array - Aquí se pueden especificar N fuentes de variables de entorno tanto de tipo `configMapRef` como `secretRef`
 - issuerSolvers: YAML array - Aquí se puede especificar N solvers del Issuer de cert-manager que sustituyen a la de por defecto.
 - cronJobAdditionalConfig: YAML dict - Aquí se pueden especificar todas las configuraciones adicionales que deba usar el CronJob (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch). ¡Cuidado! Con esta opción puedes reemplazar cualquier opción lo cual puede tener consecuencias inesperadas.
 - cronJobAdditionalConfigByEnvironment: YAML dict - Aquí se pueden especificar todas las configuraciones adicionales que deba usar el CronJob (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#cronjobspec-v1-batch) separadas por entornos (test, pre-release, release). ¡Cuidado! Con esta opción puedes reemplazar cualquier opción lo cual puede tener consecuencias inesperadas.
 - jobAdditionalConfig: YAML dict - Aquí se pueden especificar todas las configuraciones adicionales que deba usar el Job (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#jobspec-v1-batch). ¡Cuidado! Con esta opción puedes reemplazar cualquier opción lo cual puede tener consecuencias inesperadas.
 - jobAdditionalConfigByEnvironment: YAML dict - Aquí se pueden especificar todas las configuraciones adicionales que deba usar el Job (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#jobspec-v1-batch) separadas por entornos (test, pre-release, release). ¡Cuidado! Con esta opción puedes reemplazar cualquier opción lo cual puede tener consecuencias inesperadas.
 - podAdditionalConfig: YAML dict - Aquí se pueden especificar todas las configuraciones adicionales que deba usar el PodSpec (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core). ¡Cuidado! Con esta opción puedes reemplazar cualquier opción lo cual puede tener consecuencias inesperadas.
 - podAdditionalConfigByEnvironment: YAML dict - Aquí se pueden especificar todas las configuraciones adicionales que deba usar el PodSpec (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podspec-v1-core) separadas por entornos (test, pre-release, release). ¡Cuidado! Con esta opción puedes reemplazar cualquier opción lo cual puede tener consecuencias inesperadas.
 - volumes: YAML array - Aquí se puede especificar N volúmenes que se añadirán al deploy.
 - volumeClaims: YAML array - Aquí se puede especificar N volume claims que se crearán como parte del despliegue (Ver `docs/examples/template-values.yml` para ejemplo de uso).
 - volumeStorages: YAML array - Aquí se puede especificar N volume storages que se crearán como parte del despliegue (Ver `docs/examples/template-values.yml` para ejemplo de uso).
 - useOnlyAdditionalIngresses: Boolean - Por defecto False. Indica cuándo solo se usarán los ingresses adicionales especificados más abajo. **OJO**: NO se creará el ingress por defecto (el que se crea a partir de las propiedades defaultDomain y productionDomain, etc).
 - additionalIngresses:  YAML array - Aquí se puede especificar N ingresses que se crearán adicionalmente. El formato de los miembros del array es un objeto que tiene una propiedad `name` que será el nombre del ingress, una propiedad `annotations` que se mergearán con las de por defecto, una propiedad `rules` para especificar las rules del ingress y una propiedad `tls` para especificar esta propiedad del ingress. Además se puede especificar una propiedad `environment` opcionalmente para que solo se despliegue en ese entorno.
 - useOnlyAdditionalIssuers: Boolean - Por defecto False. Indica cuándo solo se usarán los issuers adicionales especificados más abajo. **OJO**: NO se creará el issuer por defecto (letsencrypt-prod).
 - additionalIssuers:  YAML array - Aquí se puede especificar N issuers que se crearán adicionalmente. El formato de los miembros del array es un objeto que tiene una propiedad `name` que será el nombre del issuer, una propiedad `privateKeySecretRef` para añadir esta propiedad al issuer y una propiedad `solvers` para especificar estos en el issuer. Además se puede especificar una propiedad `environment` opcionalmente para que solo se despliegue en ese entorno.

## Healthcheck y tests

Como parte del flujo que se describe más abajo es obligatorio tener, como mínimo, un test para que las pull requests sean válidas.

En el directorio `docs/examples` tenéis un ejemplo de un test básico.

Los tests deben colocarse en una carpeta `tests` en el root del repositorio.

## BinFlow way (link a documentación BinFlow extendida)
La forma de proceder con este nuevo template y este nuevo sistema en general es seguir la filosofía del CI / CD de una forma fiel que no nos suponga un overhead en nuestro día a día. Pongo aquí unos highlights podéis verlo en profundidad en el link.

 - **Ya no usamos gitflow**.
 - Trabajaremos en la rama develop.
 - Sólo hacer ramas de features si planteamos un cambio que puede terminar desechando todos los cambios, es decir, borrar la rama sin mergear.
 - Comitearemos a develop por lo menos una vez al día.
 - Todo lo que acaba en develop debe ser funcional y no contener errores.
 - Cuando queramos iniciar una subida a `test` tendremos que crear una pull request de develop a main que pasará los varios checks.
 - Si alguno de los checks da error se convierte en la prioridad número 1 arreglarlo y que todos los checks pasen correctamente.
 - Por último, cuando todo esté ok, mergeamos la pull request (cuidado de no eliminar develop al pulsar en la opción que da GitHub).
 - Es recomendable hacer, como mínimo, una subida al día a `test` para comprobar que todo se integra correctamente.
 - Si queremos pasar una versión a `pre-release` o a `release` seleccionamos el tag que queremos y lo convertimos en `pre-release` o `release`.

Eso sería, muy por encima, todo.

## You shall not pass!

En ocasiones queremos añadir flags temporales para hacer debugging en local y podrían terminar en una build de release. Para evitar esto se ha incorporado el comentario especial `// YSNP: `.

Este comentario hará que falle la ejecución de uno de los checks de la pull request marcando visualmente que deberíamos corregirlo antes de continuar.

## Cambiar a qué canal de Discord llegan las notificaciones

Para cambiar el canal que usa para enviar notificaciones Discord tenemos que crear un Webhook en el canal de Discord que queremos que lleguen las notificaciones. Si no tenemos permisos suficientes le pediremos a Isa o Cristian que nos lo creen. Esto nos da como resultado una URL que utilizaremos en el siguiente paso.

Después, en Github dentro del repositorio, vamos a "Settings" y a la pestaña de "Secrets".

Aquí pulsaremos en "New repository secret".

De nombre le pondremos el siguiente: `DISCORD_WEBHOOK`
Y para el valor ponemos la URL del webhook de Discord del paso anterior.

También se puede añadir una imagen distinta creando otra secret que se llame `DISCORD_AVATAR_URL` y que contenga una URL que sirva una imagen.

## Mantener actualizado el template

Una parte importante de esto es poder mantener el template actualizado, para esto el template incorpora en el package.json un par de scripts de npm `setupUpdateFromTemplate` y `updateFromTemplate`.
 - `setupUpdateFromTemplate`: establece un nuevo remote de git con el nombre de "template" que apunta al repositorio del template. **Este comando solo hay que ejecutarlo una vez**.
 - `updateFromTemplate`: este comando se traerá los cambios del template original que pueden tener conflictos en algún archivo que hayamos modificado y que tendremos que resolver a mano para asegurarnos de que elegir lo correcto.
