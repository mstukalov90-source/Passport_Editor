"""Page bootstrap config for pass_viewer map templates (json_script)."""

from django.urls import reverse


def _editor_api_urls():
    return {
        'checkRelations': reverse('check_new_object_relations'),
        'checkDgi': reverse('check_dgi_intersections'),
        'autoRemove': reverse('auto_remove_intersections'),
        'cutGeometry': reverse('cut_edited_geometry'),
        'saveNewObject': reverse('save_new_object'),
        'repairGeometry': reverse('repair_save_geometry'),
        'exportGeometry': reverse('export_new_object_geometry'),
        'listCommentPoints': reverse('list_comment_points'),
        'saveCommentPoint': reverse('save_comment_point'),
        'deleteCommentPoint': reverse('delete_comment_point'),
    }


def build_page_config(page, **extra):
    config = {'page': page, 'urls': {}, 'features': {}}
    if page in ('main', 'add_object', 'add_recap', 'split'):
        config['urls'] = _editor_api_urls()
    config.update(extra)
    return config


def home_page_config(*, need_entry_request_id, ods_source_label, owner_id=None):
    return build_page_config(
        'home',
        urls={
            'cancelPending': reverse('cancel_pending_entry'),
            'addRecap': reverse('add_recap'),
        },
        needEntryRequestId=bool(need_entry_request_id),
        odsSourceLabel=ods_source_label or 'ОДС',
        ownerId=str(owner_id) if owner_id is not None else '',
    )


def add_object_page_config(*, effective_request_id='', selected_rootid='', selected_source_label='ДТ'):
    return build_page_config(
        'add_object',
        defaultZoom=12,
        effectiveRequestId=effective_request_id or '',
        selectedRootid=selected_rootid or '',
        selectedSourceLabel=selected_source_label or 'ДТ',
        features={'pdf': True, 'selectedGeometry': False},
    )


def main_page_config(
    *,
    selected_rootid='',
    selected_name='',
    selected_request_id='',
    selected_ctid='',
    effective_request_id='',
    selected_customer_legal_person_id='',
    selected_department_legal_person_id='',
    selected_customer_legal_person_name='',
    selected_department_legal_person_name='',
    selected_startdate='',
    selected_datesurvey='',
    selected_createtype='',
    selected_source_label='ДТ',
):
    return build_page_config(
        'main',
        defaultZoom=10,
        selectedRootid=selected_rootid or '',
        selectedName=selected_name or '',
        selectedRequestId=selected_request_id or '',
        selectedRowCtid=selected_ctid or '',
        effectiveRequestId=effective_request_id or '',
        selectedCustomerLegalPersonId=selected_customer_legal_person_id or '',
        selectedDepartmentLegalPersonId=selected_department_legal_person_id or '',
        selectedCustomerLegalPersonName=selected_customer_legal_person_name or '',
        selectedDepartmentLegalPersonName=selected_department_legal_person_name or '',
        selectedStartdate=selected_startdate or '',
        selectedDatesurvey=selected_datesurvey or '',
        selectedCreatetype=selected_createtype or '',
        selectedSourceLabel=selected_source_label or 'ДТ',
        features={'pdf': True, 'selectedGeometry': True},
    )


def add_recap_page_config(
    *,
    request_id='',
    name='',
    selected_source_label='ДТ',
    selected_rootid='',
    selected_row_ctid='',
    initial_recap_id='',
):
    urls = _editor_api_urls()
    urls['saveRecap'] = reverse('save_recap_object')
    return build_page_config(
        'add_recap',
        urls=urls,
        defaultZoom=10,
        requestId=request_id or '',
        objectName=name or '',
        selectedSourceLabel=selected_source_label or 'ДТ',
        selectedRootid=selected_rootid or '',
        selectedRowCtid=selected_row_ctid or '',
        initialRecapId=initial_recap_id or '',
        features={'pdf': False, 'selectedGeometry': True},
    )


def split_object_page_config(
    *,
    selected_name='',
    selected_request_id='',
    selected_source_label='ДТ',
):
    return build_page_config(
        'split',
        selectedName=selected_name or '',
        selectedRequestId=selected_request_id or '',
        selectedSourceLabel=selected_source_label or 'ДТ',
        defaultZoom=10,
        features={'pdf': False},
    )
