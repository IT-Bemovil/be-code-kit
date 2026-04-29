Frontend (React)
import React, { useState } from "react";
import { Table, DrawForm, useResource, DS } from "@blokay/react";

export default function TableComponent({resource, jwt}) {

  const { execute, response, block, loading, reload, onExport } = useResource(
    resource,
    jwt
  );
  const [expanded, setExpanded] = useState(false);

  return (
    <>
      {!response && !loading && block && (
      <div className="blokay-box">
        <DrawForm
        resource={resource}
        jwt={jwt}
            filters={block.filters}
            title={block.title}
            execute={execute}
          />
      </div>
      )}    

      {loading && <DS.Loader/>}

      {response  && block && (
      <div>

      {block.filters.length > 0 && (
           <div className="py-10 select-none">

           <DS.Button
           variant="primary"
           onClick={() => setExpanded(!expanded)} className="cursor-pointer mb-2">Ver filtros</DS.Button>
           {expanded && (
              <DrawForm
        resource={resource}
        jwt={jwt}
            filters={block.filters}
            title={block.title}
            execute={execute}
          />
           )}
          </div>
          )}

          {(response || loading) && (
        <Table 
          title={block?.title}
          data={response?.content || {data: [], header: []}}
          onReload={reload}
          onExport={onExport}
          loading={loading}
          />
          )}
      </div>
      )}
    </>
  );
}



Backend (Typescript):
export const fn = async (req: Request, res: Response): Promise<any> => {
  const sql = `
    SELECT
      ib.businessId AS id_negocio,
      b.name AS nombre_negocio,
      CONCAT(b.personName, " ", b.personLastName) as nombres,
      b.email,
      b.cellphone as telefono,
      IF(b.parentId = 1, "directo", "") AS directo,
      i.id as id_premio,
      i.name AS premio,
      ROUND(i.award, 2) AS valor,
      ib.status as estado,
      ib.createdAt AS fecha_pago
    FROM insight_business ib
    JOIN insights i ON ib.insightId = i.id AND i.award > 0 AND i.deletedAt IS NULL
    JOIN businesses b ON b.id = ib.businessId AND b.parentId = :parentId
    WHERE ib.deletedAt IS NULL
    AND ib.createdAt not in ("2025-05-26 20:43:19", "2025-05-26 21:07:47", "2025-05-26 21:10:28", "2025-05-26 21:09:30", "2025-05-26 21:13:21", "2025-05-26 21:08:48", "2025-05-26 21:12:14", "2025-05-26 21:09:06")
    AND ib.status IN ("for_pay", "finished")
  `;

 let rows = await req.query(sql, { parentId: req.form.parentId});

 return res.table(rows)
};


const fn = async function(args:Args) { 
let sql = `select
b.id as id_cliente,
b.name as negocio,
  b.image as image, 
CONCAT(b.personName, " ", b.personLastName ) as nombres, 
b.cellphone as celular,
format(b.balance + b.profits + b.balanceTopup, 0) as saldo,
IF(b.parentId = 1, "Directo", "") as es_directo,

CONCAT(b.address, " - ", c.name) as ubi,
 b.fileRut,
 b.fileCommerce,
 b.fileDocument,
 DATE(bi.createdAt) as fecha

from insight_business bi
join businesses b on b.id = bi.businessId AND b.parentId = :parentId
left join cities c on c.id = b.cityId
where bi.insightId = 110
and bi.deletedAt is null
and bi.status = "started"
order by bi.createdAt desc`;
let result = await args.query(sql, {
...args.form,
businessId: args.session.extra1,
parentId: req.form.parentId
});


result = result.map(row => {
	const baseUrl = "https://static.bemovil.net/resources/assets/";
	
	row.image = {
		html: row.image ? `<div><a target="_blank" href="${baseUrl}${ row.image }">Foto Negocio</a></div>` : `<div></div>`
	};

	row.fileRut = {
		html: row.fileRut ? `<div><a target="_blank" href="${baseUrl}${ row.fileRut }">Rut</a></div>` : `<div></div>`
	};

	row.fileCommerce = {
		html: row.fileCommerce ? `<div><a target="_blank" href="${baseUrl}${ row.fileCommerce }">Camara y comercio</a></div>` : `<div></div>`
	};

	row.fileDocument = {
		html: row.fileDocument ? `<div><a target="_blank" href="${baseUrl}${ row.fileDocument }">Documento</a></div>` : `<div></div>`
	};

	row.estado = {
		click: "openBlock",
		args: {
			blockKey: "cambiar.estado",
			form: {
				id: row.id
			}
		},
		html: `<span style="background:#aaa; color: white; border-radius: 3px; padding: 2px 5px;">Cambiar</span>`
	};


	return row;
});


return args.table(result);
}

Jobs:
const fn = async (args: Args) => {
    const sql = `SELECT sub.id, sub.newStatusId, sub.businessStatusId
  FROM (
      SELECT
          f.id,
          CASE
              -- eliminado (partner)
              WHEN f.deletedPartner IS NOT NULL THEN 10
              -- bloqueado
              WHEN f.blockReasonId IS NOT NULL THEN 7
              -- sin actividad (nunca transaccionó)
              WHEN f.lastTransaction IS NULL THEN 6
              -- top
              WHEN f.lastTransaction > NOW() - INTERVAL 1 MONTH
                   AND (f.balance + f.profits) > 1000000 THEN 1
              -- activo
              WHEN f.lastTransaction > NOW() - INTERVAL 1 MONTH THEN 2
              -- en riesgo (entre 1 y 2 meses)
              WHEN f.lastTransaction >= NOW() - INTERVAL 2 MONTH THEN 5
              -- perdido (más de 2 meses sin transaccionar)
              ELSE 9
          END AS newStatusId,
          f.businessStatusId
      FROM businesses f
      WHERE f.deletedAt IS NULL
  ) sub
  WHERE sub.newStatusId != COALESCE(sub.businessStatusId, -1)`;

   let rows = await args.query(sql);
    args.setDatasource("writer")
    for (let row of rows) {
        let sqlUpdate = `UPDATE businesses SET businessStatusId = :businessStatusId WHERE id = :id`;
        await args.update(sqlUpdate, {
            id: row.id,
            businessStatusId: row.businessStatusId
        });
    }


    return args.message("Business status updated successfully");
};

Utils:
async function sendEmail (req, to, subject, html) {
    let body = {
      "from": "Bemovil <notificaciones@bemovil.net>",
      "to": [to],
      "subject": subject,
      "html": html
    };

    let result = await req.fetch(
      'https://api.resend.com/emails',
      {
        method: "POST",
        body: JSON.stringify(body),
        headers: {
        'Content-Type': 'application/json',
          Authorization: "Bearer re_YdaX5XMT_DXUPkYzRCEhEVbYoqhr49yWN",
        },
      },
    );
}

